#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use CGI::Carp qw ( fatalsToBrowser );

use Sirius::Common qw(debug);

use options;
use global;

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
my $lang = 'ru';

# Cookies - принимаем Cookie от клиента, ожидаем sid
my %cookies = fetch CGI::Cookie;

# Идентификатор сессии принимаем из Cookie
my $sid = ($cookies{'sid'}) ? $cookies{'sid'}->value : undef;

# Загружаем сессию с принятым ID или начинаем новую со сгенерированым идентификатором
my $cgiSession = new CGI::Session("driver:MySQL;", $sid, {Handle=>$dbh});
$cgiSession->expire('+3M');
 
# Cookie с идентификатором сессии к клиенту
my $cookie = new CGI::Cookie(-expires=>'+3M', -name=>'sid', -value=>$cgiSession->id());

# Services
my $userService = new Service::User();

my $userId = $cgiSession->param('userId');
my $user = $userService->findById($userId);
if(!$user)
{
	$cgiSession->clear('userId');
	$redirect = "/";
} 
#=======================Template Variables================
 
$vars->{'lang'} = $lang;
$vars->{'error'} = "";

if($user)
{
	$vars->{'data'}->{'users'} = $userService->countAll();
	$vars->{'data'}->{'refLink'} = "?ref=" . $user->getLogin();
	$userService->loadAccount($user);
	$vars->{'data'}->{'account'}->{'fond'} = sprintf("%.02f", $user->getAccount()->{'fond'});
    $vars->{'data'}->{'account'}->{'referal'} = sprintf("%.02f", $user->getAccount()->{'referal'});
}

#=======================Main Stage========================
if($URL =~ /logout/)
{
    $cgiSession->clear('userId');   
    $redirect = "/";
}


if($URL =~ /\/ajax(\/|$)/)
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    ajaxStage()
}
elsif($redirect)
{
    print $CGI->redirect(-uri=>$redirect, -cookie=>$cookie);
}
elsif($URL =~ /\/profile(\/|$)/)
{
    $userService->loadProfile($user);
    $vars->{'data'}->{'user'} = $user;
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/$lang/profile.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}
else
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/$lang/cab.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}

#=======================End Main Stage====================

$cgiSession->flush();
$sql->disconnect();
 
#====================== Subs =============================

# Функция вызывается, если в ссылке есть /ajax/
sub ajaxStage
{
    if($URL =~ /\/save\//)
    {
    	my $params = $CGI->Vars();
    	my $newUser = $userService->createUserFromCgiParams($params);
    	$newUser->setId($user->getId());
        $newUser->setLogin($user->getLogin());
    	unless($newUser->getPassword())
    	{
    		$newUser->set('password', $user->getPassword());
    	}
    	my $validationStatus = $userService->validate($newUser);
    	if($validationStatus->{'success'} eq 'true')
    	{
            $userService->save($newUser);
            foreach my $name("skype", "country", "phone")
            {
            	if($CGI->param($name))
            	{
                    $newUser->getProfile()->{$name} = $CGI->param($name);
            	}
            }
            $userService->saveProfile($newUser);
    	}
    	my $jsonResult = $json->encode($validationStatus);
    	print $jsonResult;
    }
}

