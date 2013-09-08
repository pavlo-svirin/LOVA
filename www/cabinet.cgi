#!/usr/bin/perl
use strict;
use utf8;

use FindBin qw($Bin);
use Log::Log4perl;
use lib "$Bin/../lib/";

use Sirius::Common qw(debug);

use options;
use global;

#=======================Variables=========================

my $log = Log::Log4perl->get_logger("cabinet.cgi");

our $sql     = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh      = $sql->connect;
my $CGI      = new CGI;
our $template = Template->new({RELATIVE=>1});
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
my $ticketDao = new DAO::Ticket();
my $gameDao = new DAO::Game(); 
my $gameStatDao = new DAO::GameStat(); 
my $budgetDao = new DAO::Budget(); 
my $userDao = new DAO::User(); 

# Services
our $userService = new Service::User();
our $optionsService = new Service::Options();
$optionsService->load();

if($URL =~ /(\w{32})/)
{
	my $emailCode = $1;
	my $user = $userService->findByEmailCode($emailCode);
	if($user)
	{
		$userDao->deleteProfile($user, 'emailCode');
		$cgiSession->param('userId', $user->getId());
		$userService->loadProfile($user);
		$user->getProfile()->{'validateEmail'} = time;
		$userService->saveProfile($user);
		$redirect = "/cab/profile/";
	}
}

my $userId = $cgiSession->param('userId');
my $user = $userDao->findById($userId);

my $lang = &getLang();

our $emailService = new Service::Email(userService => $userService, lang => $lang);
our $htmlContentService = new Service::HtmlContent(dao => $htmlContentDao, lang => $lang, page => 'CABINET');
our $ticketService = new Service::Ticket();
our $gameService = new Service::Game();

# Controllers
my $ticketsController = new Controller::Tickets();
my $reportsController = new Controller::Reports();

#=======================Template Variables================
 
$vars->{'lang'} = $lang;
$vars->{'error'} = "";

if($user)
{
	$vars->{'data'}->{'users'}->{'active'} = $userService->countActive();
	$vars->{'data'}->{'refLink'} = "?ref=" . $user->getLogin();
    $vars->{'data'}->{'referals'}->{'active'} = $userDao->countActiveReferals($user);
    $vars->{'data'}->{'referals'}->{'all'} = $userDao->countReferals($user);
    
	$userService->loadAccount($user);
    $vars->{'data'}->{'account'}->{'personal'} = sprintf("%.02f", $user->getAccount()->{'personal'});
	$vars->{'data'}->{'account'}->{'fond'} = sprintf("%.02f", $user->getAccount()->{'fond'});
    $vars->{'data'}->{'account'}->{'referal'} = sprintf("%.02f", $user->getAccount()->{'referal'});
    $vars->{'data'}->{'account'}->{'win'} = sprintf("%.02f", $user->getAccount()->{'win'});
    $vars->{'data'}->{'account'}->{'bonus'} = $user->getAccount()->{'bonus'};
    
    $userService->loadProfile($user);
    $vars->{'data'}->{'user'} = $user;
    $vars->{'data'}->{'profile'}->{'validateEmail'} = $user->getProfile()->{'validateEmail'};

    # Lottery options 
    $vars->{'data'}->{'options'}->{'lottery'}->{'totalWin'} = $optionsService->get('totalWin');
    $vars->{'data'}->{'options'}->{'lottery'}->{'maxNumber'} = $optionsService->get('maxNumber');
    $vars->{'data'}->{'options'}->{'lottery'}->{'maxNumbers'} = $optionsService->get('maxNumbers');
    $vars->{'data'}->{'options'}->{'lottery'}->{'maxGames'} = $optionsService->get('maxGames');
    $vars->{'data'}->{'options'}->{'lottery'}->{'maxTickets'} = $optionsService->get('maxTickets');
    $vars->{'data'}->{'options'}->{'lottery'}->{'gamePrice'} = $optionsService->get('gamePrice');
    $vars->{'data'}->{'options'}->{'lottery'}->{'ticketsLimit'} = $optionsService->get('ticketsLimit');
        
    my @games = $gameService->findNextGames(2);
    for (my $i = 0; $i < @games ; $i++)
    {
        $games[$i] = toTimeZone($games[$i], 'Europe/Kiev');
    }
    $vars->{'data'}->{'options'}->{'lottery'}->{'nextGames'} = \@games; 
    
    my @activeTickets = $ticketDao->findActive($user->getId());
    $vars->{'data'}->{'lottery'}->{'session'}->{'tickets'}->{'active'} = \@activeTickets;
    my @notPaidTickets = $ticketDao->findNotPaid($user->getId());
    $vars->{'data'}->{'lottery'}->{'session'}->{'tickets'}->{'new'}  = \@notPaidTickets;
    $vars->{'data'}->{'lottery'}->{'session'}->{'totalSum'} = sprintf("%.02f", $ticketService->calcTicketsSum(@notPaidTickets));
    my $ticketsCount = scalar @activeTickets + scalar @notPaidTickets;
    $vars->{'data'}->{'lottery'}->{'session'}->{'tickets'}->{'limit'}  = 1 if ($optionsService->get('ticketsLimit') && ($optionsService->get('ticketsLimit') >= $ticketsCount));

    my $lastGame =  $gameDao->findLast();
    if($lastGame)
    {
        my $schedule = toTimeZone($lastGame->getSchedule(), 'Europe/Kiev');
        $lastGame->setSchedule($schedule);
        $vars->{'data'}->{'lottery'}->{'last'}->{'game'} = $lastGame;
        
        my @userTickets = $ticketDao->findByGameAndUser($lastGame->getId(), $user->getId());
    	$vars->{'data'}->{'lottery'}->{'last'}->{'userTickets'} = \@userTickets;
    	
    	my $budget = $budgetDao->find({ game_id => $lastGame->getId() });
	    $vars->{'data'}->{'lottery'}->{'last'}->{'win'} = $budget->getPrize() if ($budget);
	    my $lastGameStat = $gameStatDao->findByGameId($lastGame->getId());
	    if ($lastGameStat)
	    {
		    my $lastGameResult;
		    my $lastGameTotalTickets = $lastGameStat->getTickets();
		    if ($lastGameTotalTickets)
		    {
		        my $maxGuessed = $lastGameStat->getMaxGuessed();
			    for (my $i = $optionsService->get('maxNumbers'); $i >= $maxGuessed; $i--)
			    {
			        $lastGameResult->{$i} = 0;
			        if ($i == $maxGuessed)
			        {
                        my $tickets = $lastGameStat->getTickets($i);
		                $lastGameResult->{$i} = $tickets . " " . $htmlContentService->getContent('LOTTERY_STAT_TICKETS', $tickets);
			        }
			    }
		    }
		    
		    $vars->{'data'}->{'lottery'}->{'last'}->{'stat'} = $lastGameResult;
        }
    }
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
my $controller = Controller::Abstract::_getByUrl($URL);
if($controller)
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
    $log->debug("Lang: $lang");
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
    elsif ($userDao->findByEmail($email))
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_EMAIL_EXISTS');
    }
    elsif ($userService->countLatestInvitedUsers({ referal => $user->getLogin(), interval => 60 }) > $optionsService->get("invitesLimit"))
    {
        $result->{'error'} = $htmlContentService->getContent('INVITE_ALERT_LIMIT');
    }
    elsif (addressInGreyList($email))
    {
        $result->{'error'} = "На данный почтовый ящик уже отправлено достаточно приглашений.<br>Попробуйте отправить приглашение на другой почтовый ящик.";
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

sub toTimeZone
{
	my ($date, $tz) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})/; 
    my $dt = DateTime->new(
        year      => $1,
        month     => $2,
        day       => $3,
        hour      => $4,
        minute    => $5,
        second    => 0,
        time_zone => 'UTC'
    );
    $dt->set_time_zone($tz);
    return $dt->ymd("-") . ' ' . sprintf("%02d:%02d", $dt->hour(), $dt->minute());        
}

# Find email in grey list
sub addressInGreyList
{
    my $email = shift;
    return $::sql->count('grey_emails', " WHERE `email`=" . $::sql->q($email));
}