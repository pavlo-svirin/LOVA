#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use CGI::Carp qw ( fatalsToBrowser );

use options;
use global;

use Sirius::Common qw(debug);

#=======================Variables=========================

our $sql      = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh      = $sql->connect;
my $CGI      = new CGI;
my $template = Template->new({RELATIVE=>1});

my $json     = JSON->new->allow_nonref;


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
my $userService = new Service::User();
my $optionsService = new Service::Options();
my $schedulerService = new Service::Scheduler(optionsService => $optionsService);
my $emailService = new Service::Email(userService => $userService);

#=======================Template Variables================

#=======================Main Stage========================	
if ($URL =~ /\/options\/save(\/|$)/)
{
    foreach (keys %{$CGI->Vars})
    {
        $optionsService->set($_, $CGI->param($_));
    }
    my $nextAccountRun = $schedulerService->calcNextAccountTime();
    $optionsService->set('nextAccountTime', $nextAccountRun);
    $optionsService->save();
    $optionsService->setAdminPassword();
    $redirect = '/admin/';
}

$optionsService->load();

#--------Headers---------
if($URL =~ /\/ajax(\/|$)/)
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
    elsif($URL =~ /\/send\//)
    {
    	my $subject = $CGI->param("subject");
        my $body = $CGI->param("body");
        my $recipients = $CGI->param("emails");
        if($CGI->param('rcpt') eq 'all')
        {
            $emailService->sendToAllUsers($subject, $body);
        }
        elsif($CGI->param('rcpt') eq 'subscribers')
        {
            $emailService->sendToSubscribedUsers($subject, $body);
        }
        else
        {
            $emailService->sendToRecipients($subject, $body, $recipients);
        }
    }    
    elsif(($URL =~ /\/users\//) && ($URL =~ /\/chart\//))
    {
    	my %usersByDate;
        my @users = $userService->findCreatedInRange({
            from => $CGI->param('from'),
            to => $CGI->param('to')
        });

        foreach my $user (@users)
        {
        	my $date = $user->getCreatedByScale($CGI->param('scale')); 
            $usersByDate{$date}->{'registered'}++;
            if($user->getReferal())
            {
                $usersByDate{$date}->{'referals'}++;
            }
        }

        my $result->{'success'} = JSON::true;
        $result->{'data'} = (); 
        for my $date (sort keys %usersByDate)
        {
        	my $row->{'date'} = $date;
        	$row->{'registered'} = $usersByDate{$date}->{'registered'} || 0;
            $row->{'referals'} = $usersByDate{$date}->{'referals'} || 0;
        	push(@{$result->{'data'}}, $row);
        }
        print $json->encode($result);                
     
    }
    elsif($URL =~ /\/users\//)
    {
        printAllSimpleObjects($userService);
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
  my $response->{success} = 'true';
  foreach my $obj ($service->findAll())
  {
    push(@{$response->{data}}, $obj->getData());
  }
  print $json->encode($response);
}

