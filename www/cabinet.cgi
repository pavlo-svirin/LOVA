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

# Services
my $userService = new Service::User();
my $optionsService = new Service::Options();
$optionsService->load();

if($URL =~ /(\w{32})/)
{
	my $emailCode = $1;
	my $user = $userService->findByEmailCode($emailCode);
	if($user)
	{
		$userService->deleteProfile($user, 'emailCode');
		$cgiSession->param('userId', $user->getId());
		$userService->loadProfile($user);
		$user->getProfile()->{'validateEmail'} = time;
		$userService->saveProfile($user);
		$redirect = "/cab/profile/";
	}
}

my $userId = $cgiSession->param('userId');
my $user = $userService->findById($userId);

my $lang = &getLang();
my $emailService = new Service::Email(userService => $userService);
my $htmlContentService = new Service::HtmlContent(dao => $htmlContentDao, lang => $lang, page => 'CABINET');


#=======================Template Variables================
 
$vars->{'lang'} = $lang;
$vars->{'error'} = "";

if($user)
{
	$vars->{'data'}->{'users'}->{'active'} = $userService->countActive();
	$vars->{'data'}->{'refLink'} = "?ref=" . $user->getLogin();
    $vars->{'data'}->{'referals'} = $userService->countReferals($user);
	$userService->loadAccount($user);
	$vars->{'data'}->{'account'}->{'fond'} = sprintf("%.02f", $user->getAccount()->{'fond'});
    $vars->{'data'}->{'account'}->{'referal'} = sprintf("%.02f", $user->getAccount()->{'referal'});
    $userService->loadProfile($user);
    $vars->{'data'}->{'user'} = $user;
    $vars->{'data'}->{'profile'}->{'like'} = $user->getProfile()->{'like'};
    $vars->{'data'}->{'profile'}->{'validateEmail'} = $user->getProfile()->{'validateEmail'};

    # Lottery options 
    $vars->{'data'}->{'options'}->{'lotery'}->{'maxNumber'} = 27;
    
    if((time - $user->getCreatedUnixTime()) > 7 * 24 * 60 * 60)
    {
        $vars->{'data'}->{'profile'}->{'referalDisabled'} = 'disabled';
    }
   
    # Force user to fill profile 
    if((!$user->getLogin() || !$user->getFirstName() || !$user->getEmail()) && not ($URL =~ /\/profile(\/|$)/))
    {
    	$redirect = "/cab/profile/";
    }
}
else
{
    $cgiSession->clear('userId');
    $redirect = "/login/";
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
	$vars->{'content'} = $htmlContentService->getContentForPage('PROFILE', $lang);
    $userService->loadProfile($user);
    $vars->{'data'}->{'user'} = $user;
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/profile.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
}
else
{
	$vars->{'content'} = $htmlContentService->getContentForPage('CABINET', $lang);
    print $CGI->header(-expires=>'now', -charset=>'UTF-8', -pragma=>'no-cache', -cookie=>$cookie);
    $template->process("../tmpl/cab.tmpl", $vars) || die "Template process failed: ", $template->error(), "\n";
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
    	saveProfile();
    }
    elsif($URL =~ /\/invite\//)
    {
    	sendInvite();
    }
    elsif($URL =~ /\/send\//)
    {
    	$emailService->sendFirstEmail($user);
    }
}

sub saveProfile
{
    my $params = $CGI->Vars();
    my $newUser = $userService->createUserFromCgiParams($params);
    $newUser->setId($user->getId());
    
    # Do not allow change login if it already exists
    if($user->getLogin())
    {
        $newUser->setLogin($user->getLogin());
    	
    }

    # Do not allow change referal after 7 days
    if((time - $user->getCreatedUnixTime()) > 7 * 24 * 60 * 60)
    {
        $newUser->setReferal($user->getReferal());
    }
    
    # Save old password        
    unless($newUser->getPassword())
    {
        $newUser->set('password', $user->getPassword());
    }
    
    my $validationStatus = $userService->validate($newUser);
    $newUser->getProfile()->{"subscribe"} = "false";
    if($validationStatus->{'success'} eq 'true')
    {
        $userService->save($newUser);
        foreach my $name("skype", "country", "phone", "subscribe", "lang")
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

sub sendInvite
{
    my $result->{'success'} = JSON::false;
    my $name = $CGI->param('first_name');
    my $email = $CGI->param('email');
    my $numAtSign = () = $email =~ /\@/gi;
    if (!$name || !$email)
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_REQUIRED_FIELDS');
    }
    elsif(length($name) > 255)
    {
    	$result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_NAME_TO_LONG');
    }
    elsif($numAtSign != 1)
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_ONE_EMAIL_ALLOWED');
    }
    elsif ($userService->findByEmail($email))
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_EMAIL_EXISTS');
    }
    elsif ($userService->countLatestInvitedUsers({ referal => $user->getLogin(), interval => 60 }) > $optionsService->get("invitesLimit"))
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_LIMIT');
    }
    else
    {
        my $params = $CGI->Vars();
        my $inviteUser = $userService->createUserFromCgiParams($params);
        $inviteUser->setReferal($user->getLogin());
        $inviteUser->setPassword(Sirius::Common::GenerateRandomString());
        $userService->save($inviteUser);
        $emailService->sendInviteEmail($inviteUser);
        $result->{'success'} = JSON::true;
    }
    print $json->encode($result);	
}

sub getLang
{
    my $lang = $cgiSession->param('lang');
    $userService->loadProfile($user);
    $lang = $user->getProfile()->{'lang'} if($user);	
	$lang = $1 if($URL =~ /(ru|ua|en)/);
	return $lang || 'ru';
}
