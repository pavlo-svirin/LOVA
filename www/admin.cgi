#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use CGI::Carp qw ( fatalsToBrowser );
use Encode;
use Storable qw( nfreeze );

use options;
use global;

#=======================Variables=========================

our $sql     = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh      = $sql->connect;
my $CGI      = new CGI;
my $template = Template->new({RELATIVE=>1});
my $json     = JSON->new->allow_nonref;
my $log      = Log::Log4perl->get_logger("admin.cgi");

# Используемые переменные
# vars - переменные шаблона TT
# lang - текущий язык, устанавливается функцией get_lang
# redirect - флаг переадрессации,содержит новый адрес
my ($vars, $redirect); 

# Cookies - принимаем Cookie от клиента, ожидаем sid
my %cookies = fetch CGI::Cookie;

# Идентификатор сессии принимаем из Cookie
my $sid = ($cookies{'sid'}) ? $cookies{'sid'}->value : undef;
# Загружаем сессию с принятым ID или начинаем новую со сгенерированым идентификатором
my $cgiSession = new CGI::Session("driver:MySQL;", $sid, {Handle=>$dbh});
$cgiSession->expire('+3M');

# Cookie с идентификатором сессии к клиенту
my $cookie = new CGI::Cookie(-expires=>'+3M', -name=>'sid', -value=>$cgiSession->id());

# Сервисы
our $userService = new Service::User();
our $optionsService = new Service::Options();
our $schedulerService = new Service::Scheduler(optionsService => $optionsService);
our $emailService = new Service::Email(userService => $userService);
our $gameService = new Service::Game();
our $ticketService = new Service::Ticket();

# DAO
my $emailTemplateDao = new DAO::EmailTemplates();
my $htmlContentDao = new DAO::HtmlContent();
my $ticketDao = new DAO::Ticket();
my $gameDao = new DAO::Game();
my $scheduleDao = new DAO::Schedule();

# Controllers
our $controllers = {};
my $gamesController = new Controller::Games();
my $budgetController = new Controller::Budget();
my $usersController = new Controller::Users();
my $ticketsController = new Controller::Tickets();

#=======================Template Variables================

#=======================Main Stage========================	
if ($URL =~ /\/options\/save(\/|$)/)
{
	$log->info("Saving options.");
    foreach (keys %{$CGI->Vars})
    {
    	$log->debug("Option '", $_, "' set to '", $CGI->param($_) , "'");
        $optionsService->set($_, $CGI->param($_));
    }
    $optionsService->save();
    $optionsService->setAdminPassword();
    $redirect = '/admin/';
}

$optionsService->load();

my $controller = Controller::Abstract::_getByUrl($URL);
$log->debug("URL: ", $URL);
$log->debug("Controller: ", $controller->getName()) if ($controller);
if ($controller)
{
    my $params = $CGI->Vars();
    my $response = $controller->process($URL, $params);
    if($response->{'type'} eq "redirect")
    {
        print $CGI->redirect(-uri => $response->{'data'}, -cookie => $cookie);
    }
    elsif($response->{'type'} eq "ajax")
    {
        print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
        print $json->encode($response->{'data'});       
    }
    elsif($response->{'type'} eq "html")
    {
        print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
        print $response->{'data'};
    }
    else
    {
        print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    }
}
elsif($URL =~ /\/ajax(\/|$)/)
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    ajaxStage();
}
elsif($redirect)
{
    print $CGI->redirect(-uri=>$redirect, -cookie=>$cookie);
}
else
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/admin.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}

#=======================End Main Stage====================

$cgiSession->flush();
$sql->disconnect();
 
#====================== Subs =============================

# Функция вызывается, если в ссылке есть /ajax/
sub ajaxStage
{
    if($URL =~ /\/options\//)
    {
        printOptions();
    }
    elsif( $URL =~ /\/assignPrizeTickets\// )
    {
       $userService->assignPrizeTickets(); 
    }
    elsif($URL =~ /\/send\//)
    {
    	my $subject = $CGI->param("subject");
    	Encode::from_to($subject, 'utf-8', 'cp1251');
        my $body =  $CGI->param("body");
        Encode::from_to($body, 'utf-8', 'cp1251');
        my $recipients = $CGI->param("emails");
        
         my $lightweight_fh  = $CGI->upload('template');
         if (defined $lightweight_fh)
         {
         	 $body = '';
         	 my $io_handle = $lightweight_fh->handle;
             while (my $chars = $io_handle->read(my $buffer, 20480))
         	 {
         	 	$body .= $buffer;
         	 }
         }

        # Send mass emails in background
        my $schedule = new Data::Schedule();
        $schedule->setSchedule('NOW');
        $schedule->setStatus('SCHEDULED');
        $schedule->setModule("Service::Email");
        my @params = ($subject, $body);
            	
        if($CGI->param('rcpt') eq 'all')
        {
            $schedule->setMethod('sendToAllUsers');
        }
        elsif($CGI->param('rcpt') eq 'subscribers')
        {
            $schedule->setMethod('sendToSubscribedUsers');
        }
        else
        {
            $schedule->setMethod('sendToRecipients');
            push(@params, $recipients);	
        }
        $schedule->setParams( nfreeze(\@params) );
        $scheduleDao->save($schedule);
        
    }    
    elsif (($URL =~ /\/emailTemplate\//) && ($URL =~ /\/load\//))
    {
    	my $response->{'success'} = JSON::true;
    	printAllSimpleObjects($emailTemplateDao);
    }
    elsif (($URL =~ /\/emailTemplate\//) && ($URL =~ /\/save\//))
    {   
    	my $params = $CGI->Vars();
    	my $tmpl = new Data::EmailTemplate(%$params);
    	$emailTemplateDao->save($tmpl);
        my $response->{'success'} = JSON::true;
        print $json->encode($response);
    	
    }    
    elsif (($URL =~ /\/emailTemplate\//) && ($URL =~ /\/delete\//))
    {
    	my $id = $CGI->param('id');
    	my $tmpl = $emailTemplateDao->findById($id);
    	$emailTemplateDao->delete($tmpl);
        my $response->{'success'} = JSON::true;
        print $json->encode($response);
    }
    elsif (($URL =~ /\/htmlContent\//) && ($URL =~ /\/load\//))
    {
    	my $lang = $CGI->param('lang');
    	my $page = $CGI->param('page');
        my $response->{'success'} = JSON::true;
        my @objects = $htmlContentDao->find({ lang => $lang, page => $page });
        foreach my $obj (@objects)
        {
            push(@{$response->{data}}, $obj->getData());
        }
        print $json->encode($response);
    }
    elsif (($URL =~ /\/htmlContent\//) && ($URL =~ /\/save\//))
    {   
        my $params = $CGI->Vars();
        my $content = new Data::HtmlContent(%$params);
        $htmlContentDao->save($content);
        my $response->{'success'} = JSON::true;
        print $json->encode($response);
        
    }    
    elsif (($URL =~ /\/htmlContent\//) && ($URL =~ /\/delete\//))
    {
        my $id = $CGI->param('id');
        my $content = $htmlContentDao->findById($id);
        $htmlContentDao->delete($content);
        my $response->{'success'} = JSON::true;
        print $json->encode($response);
    }
}

sub printOptions()
{
  my @options;
  foreach($optionsService->getAllNames())
  {
    push(@options, $_ . ":" . $json->encode($optionsService->get($_)));
  }
  print "{success: true, data: { " . join(',', @options) . "}}";
}

sub printAllSimpleObjects
{
  my $service = shift;
  my $response->{success} = JSON::true;;
  foreach my $obj ($service->findAll())
  {
    push(@{$response->{data}}, $obj->getData());
  }
  print $json->encode($response);
}

