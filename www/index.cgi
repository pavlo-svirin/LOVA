#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../lib/";

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

# Cookies - принимаем Cookie от клиента, ожидаем sid
my %cookies = fetch CGI::Cookie;

# Идентификатор сессии принимаем из Cookie
my $sid = ($cookies{'sid'}) ? $cookies{'sid'}->value : undef;

# Загружаем сессию с принятым ID или начинаем новую со сгенерированым идентификатором
my $cgiSession = new CGI::Session("driver:MySQL;", $sid, {Handle=>$dbh});
$cgiSession->expire('+3M');
 
# Cookie с идентификатором сессии к клиенту
my $cookie = new CGI::Cookie(-expires=>'+3M', -name=>'sid', -value=>$cgiSession->id());

# DAO
my $htmlContentDao = new DAO::HtmlContent();
my $userDao = DAO::User->new();

# Services
our $userService = new Service::User();
our $emailService = new Service::Email(userService => $userService);
our $optionsService = new Service::Options();
$optionsService->load();

my $lang = &getLang();
our $htmlContentService = new Service::HtmlContent(dao => $htmlContentDao, lang => $lang, page => 'MAIN');


checkUserLogin();
checkReferal();

#=======================Template Variables================
 
$vars->{'lang'} = $lang;
$vars->{'error'} = "";
$vars->{'url'} = $URL;
$vars->{'userId'} = $cgiSession->param('userId');
$vars->{'content'} = $htmlContentService->getContentForPage('MAIN', $lang);

#=======================Main Stage========================

if($URL =~ /\/ajax(\/|$)/)
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    ajaxStage()
}
elsif($redirect)
{
    print $CGI->redirect(-uri=>$redirect, -cookie=>$cookie);
}
else
{
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/main.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}

#=======================End Main Stage====================

$cgiSession->flush();
$sql->disconnect();
 
#====================== Subs =============================

# Функция вызывается, если в ссылке есть /ajax/
sub ajaxStage
{
    if($URL =~ /\/register\//)
    {
    	my $params = $CGI->Vars();
    	my $user = $userService->createUserFromCgiParams($params);
    	my $validationStatus = $userService->validate($user);
    	if($validationStatus->{'success'} eq 'true')
    	{
    		$user->setReferal($cgiSession->param('ref'));
            $userService->save($user);
            $userService->loadProfile($user);
            $user->getProfile()->{'lang'} = $lang;
            $user->getProfile()->{'subscribe'} = 'true';
            $userService->saveProfile($user);
            $emailService->sendFirstEmail($user);
            $cgiSession->param('userId', $user->getId());
    	}
    	my $jsonResult = $json->encode($validationStatus);
    	print $jsonResult;
    }
    elsif($URL =~ /\/restore\//)
    {
    	my $result->{'success'} = 'false';

        my $user = $userDao->findByLoginOrEmail({
        	login => $CGI->param("login"),
        	email => $CGI->param("email")
        });
        if($user)
        {
            $emailService->sendPasswordEmail($user);
            $result->{'success'} = 'true';
        }
    	print $json->encode($result);
    }
    elsif($URL =~ /\/like\//)
    {
    	my $like = $optionsService->get('like') + 1;
    	$optionsService->set('like', $like);
    	$optionsService->save();
    }
}

sub checkUserLogin
{
    if($URL =~ /\/login(\/|$)/)
    {
    	my $email = $CGI->param("email");
        my $pwd = $CGI->param("password");
    	my $user = $userDao->findByEmail($email);
    	if($user && $user->checkPassword($pwd))
    	{
            $cgiSession->param('userId', $user->getId());
            $redirect = "/cab/";   		
    	}
    }
}

sub checkReferal
{
	my $ref = $CGI->param('ref');
	if($ref && $userDao->findByLogin($ref))
	{
        $cgiSession->param('ref', $ref);       
	}
}

sub getLang
{
    my $lang = $cgiSession->param('lang');
    my $userId = $cgiSession->param('userId'); 
    if($userId)
    {
    	my $user = $userDao->findById($userId);
    	$userService->loadProfile($user);
        $lang = $user->getProfile()->{'lang'} if($user);    
    }
    if($URL =~ /(ru|ua|en)/)
    {
        $lang = $1; 
    	$cgiSession->param('lang', $lang);
    }
    return $lang || 'ru';
}
