#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use CGI::Carp qw ( fatalsToBrowser );
use Encode;

use options;
use global;

use Sirius::Common qw(debug);

#=======================Variables=========================

our $sql     = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
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

my $emailTemplateDao = new DAO::EmailTemplates();
my $htmlContentDao = new DAO::HtmlContent();
my $ticketDao = new DAO::Ticket();
my $gameDao = new DAO::Game();

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
            $userService->loadProfile($user);
            my $activationDate = $user->getActivatedByScale($CGI->param('scale'));
            if ($activationDate)
            {
                $usersByDate{$activationDate}->{'activated'}++;
            }
            
        }

        my $result->{'success'} = JSON::true;
        $result->{'data'} = (); 
        for my $date (sort keys %usersByDate)
        {
        	my $row->{'date'} = $date;
        	$row->{'registered'} = $usersByDate{$date}->{'registered'} || 0;
        	$row->{'activated'} = $usersByDate{$date}->{'activated'} || 0;
            $row->{'referals'} = $usersByDate{$date}->{'referals'} || 0;
        	push(@{$result->{'data'}}, $row);
        }
        print $json->encode($result);                
     
    }
    elsif($URL =~ /\/users\//)
    {
        my $params = $CGI->Vars();
        my $response->{'success'} = JSON::true;
        $response->{'total'} = $userService->countExtJs($params);
        my @users = $userService->findExtJs($params);
        foreach my $user (@users)
        {
        	my $data = $user->getData();
        	$data->{'meta'}->{'referals'} = $userService->countReferals($user);
            push(@{$response->{data}}, $data);
		}
		print $json->encode($response);
    }
    elsif (($URL =~ /\/user\//) && ($URL =~ /\/delete\//))
    {
    	my $user = $userService->findById($CGI->param('id'));
        my $response->{'success'} = JSON::false;
    	if($user)
    	{
    		$userService->deleteUser($user);
    		$response->{'success'} = JSON::true;
    	}
    	print $json->encode($response);
    } 
    elsif (($URL =~ /\/user\//) && ($URL =~ /\/load\//))
    {
        my $user = $userService->findById($CGI->param('id'));
        my $response->{'success'} = JSON::false;
        if($user)
        {
        	$userService->loadProfile($user);
        	$userService->loadAccount($user);
        	if($user->getProfile()->{'validateEmail'})
        	{
        		$user->getProfile()->{'validateEmail'} = JSON::true;
        	}
            if($user->getProfile()->{'like'})
            {
                $user->getProfile()->{'like'} = JSON::true;
            }
        	my $data =  $user->getData();
            $data->{'meta'}->{'referals'} = $userService->countReferals($user);
            push(@{$response->{data}}, $data);
            $response->{'success'} = JSON::true;
        }
        print $json->encode($response);
    }
    elsif (($URL =~ /\/user\//) && ($URL =~ /\/save\//))
    {
        my $user = $userService->findById($CGI->param('id'));
        $userService->loadProfile($user);
        $userService->loadAccount($user);
        # verify login and email
        $user->setLogin($CGI->param('login'));
        $user->setEmail($CGI->param('email'));
        $user->setFirstName($CGI->param('first_name'));
        $user->setLastName($CGI->param('last_name'));
        if($CGI->param('password'))
        {
            $user->setPassword($CGI->param('password'));
        }
        $user->setReferal($CGI->param('referal'));
        
        $user->getProfile()->{'skype'} = $CGI->param('profile.skype');
        $user->getProfile()->{'phone'} = $CGI->param('profile.phone');
        $user->getProfile()->{'country'} = $CGI->param('profile.country');
        $user->getProfile()->{'lang'} = $CGI->param('profile.lang');

        $user->getAccount()->{'personal'} = $CGI->param('account.personal');
        $user->getAccount()->{'fond'} = $CGI->param('account.fond');
        $user->getAccount()->{'referal'} = $CGI->param('account.referal');
        
        $userService->save($user);
        $userService->saveProfile($user);
        $userService->saveAccount($user);
        my $response->{'success'} = JSON::true;
        print $json->encode($response);
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
    elsif (($URL =~ /\/tickets\//) && ($URL =~ /\/load\//))
    {
        my $response->{'success'} = JSON::true;
        my $params = $CGI->Vars();
        my @objects = $ticketDao->findExtJs($params);
        foreach my $obj (@objects)
        {
        	my $jsonObj = $obj->getData();
        	$jsonObj->{'total'} = $obj->getGames() * $obj->getGamePrice();
            push(@{$response->{data}}, $jsonObj);
        }
        print $json->encode($response);
    }    
    elsif (($URL =~ /\/games\//) && ($URL =~ /\/load\//))
    {
        my $response->{'success'} = JSON::true;
        my $params = $CGI->Vars();
        my @objects = $gameDao->findExtJs($params);
        foreach my $obj (@objects)
        {
            my $jsonObj = $obj->getData();
            push(@{$response->{data}}, $jsonObj);
        }
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

