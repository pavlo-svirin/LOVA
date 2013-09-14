package Service::Email;
use strict;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP;
use Email::Simple;
use Log::Log4perl;

my $log = Log::Log4perl->get_logger("Service::Email");

$Service::Email::SMTP_HOST ||= 'localhost';
$Service::Email::FROM_ADDRESS ||= 'LOVA <send.lova@pemes.net>';
@Service::Email::BLACK_LIST = ('mail.ru', 'bk.ru', 'list.ru', 'inbox.ru');

require DAO::User;
my $userDao = new DAO::User();

sub new
{
    my $proto = shift;                 # извлекаем имя класса или указатель на объект
    my $class = ref($proto) || $proto; # если указатель, то взять из него имя класса
    my $self  = {};
    my %params = @_;                   # приём данных из new(param=>value)
    foreach (keys %params){
        $self->{$_} = $params{$_};
    }
    bless($self, $class);              # гибкий вызов функции bless
    return $self;
}

sub sendFirstEmail
{
    my ($self, $user) = @_;

    $::userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $::userService->saveProfile($user);
    
    my $tmpl = DAO::EmailTemplates->findByCodeAndLang('FIRST_EMAIL', $lang);
    if($tmpl)
    {
     	my $vars = {};
    	$vars->{'emailCode'} = $emailCode; 
    	$tmpl->setTemplateVars($vars);
    	$self->sendEmailTemplate($user, $tmpl)
    }
}

sub sendPasswordEmail
{
    my ($self, $user) = @_;
    
    $::userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $::userService->saveProfile($user);
    
    my $tmpl = DAO::EmailTemplates->findByCodeAndLang('PASSWORD_RESET', $lang);
    if($tmpl)
    {
        my $vars = {};
        $vars->{'emailCode'} = $emailCode; 
        $tmpl->setTemplateVars($vars);
        $self->sendEmailTemplate($user, $tmpl)
    }
}

sub sendInviteEmail
{
    my ($self, $user) = @_;

    my $email = $user->getEmail();
    if(_addressInBlackList($email))
    {
    	$log->warn("Cannot send invite because email: '", $email, "' is in black list.");
    	return;
    }
   
    $::userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $::userService->saveProfile($user);
    
    my $tmpl = DAO::EmailTemplates->findByCodeAndLang('INVITE', $lang);
    if($tmpl)
    {
        my $vars = {};
        $vars->{'emailCode'} = $emailCode;
        $vars->{'rcptName'} = $user->getFirstName();
        $vars->{'senderLogin'} = $user->getReferal();

        $vars->{'senderFirstName'} = "";
        $vars->{'senderLastName'} = "";
        
        my $invitee = $userDao->find({ login => $user->getReferal() });
        if($invitee)
        {
        	$vars->{'senderFirstName'} = $invitee->getFirstName();
            $vars->{'senderLastName'} = $invitee->getLastName();
        }

        $tmpl->setTemplateVars($vars);
        $self->sendEmailTemplate($user, $tmpl)
    }
}

sub sendEmailTemplate
{
    my ($self, $user, $tmpl) = @_;
    
    my $userName = $user->getFirstName() . ' ' . $user->getLastName();
    my $to = $userName . "<" . $user->getEmail() . ">";
    my $subject = $tmpl->getSubject();
    my $body = $tmpl->getBody();
    
	_sendPlainEmail($to, $subject, $body);
}

sub sendToAllUsers
{
    my ($self, $subject, $body) = @_;
    my @users = $userDao->findActive();
    
    $log->info("Sending message to all activated users. Total num of email: ", scalar @users);
    my $sent = 0;
    
    foreach my $user (@users)
    {
        my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
        my $email = $userName . " <" . $user->getEmail() . ">";
        
        $log->trace("Active recipient: ", $user->getEmail());
        
        eval 
        {
            _sendHtmlEmail($email, $subject, $body);
            $sent++;
        };
        $log->error("Cannot send email to: ", $user->getEmail(), " Error was: ", $@) if ($@);
    }
    
    $log->info("Sent $sent emails.");
    return $sent;
}

sub sendToSubscribedUsers
{
    my ($self, $subject, $body) = @_;
    my @users = $userDao->findSubscribed();
    
    $log->info("Sending message to subscribed users. Total num of email: ", scalar @users);
    my $sent = 0;
    
    foreach my $user (@users)
    {
        my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
        my $email = $userName . " <" . $user->getEmail() . ">";
        $log->trace("Subscribed recipient: ", $user->getEmail());
        
        eval 
        {
            _sendHtmlEmail($email, $subject, $body);
            $sent++;
        };
        $log->error("Cannot send email to: ", $user->getEmail(), " Error was: ", $@) if ($@);
    }
    
    $log->info("Sent $sent emails.");
    return $sent;
}

sub sendToRecipients
{
    my ($self, $subject, $body, $recipients) = @_;
    
    $log->info("Sending message to individual recipients. Total num of email: ", scalar split(',', $recipients));
    my $sent = 0;
    
	foreach my $email (split(',', $recipients))
	{
        $log->trace("Recipient: ", $email);
        eval {
		    _sendHtmlEmail($email, $subject, $body);
            $sent++;
        };
        $log->error("Cannot send email to: ", $email, " Error was: ", $@) if ($@);
	}
	
    $log->info("Sent $sent emails.");
	return $sent;
}

sub _sendPlainEmail
{
    my ($to, $subject, $body) = @_;
    
    my $message = Email::Simple->create(
        header => [
            From    => $Service::Email::FROM_ADDRESS,
            To      => $to,
            Subject => $subject
        ],
        body => $body
    );
    $message->header_set("Content-Type" => 'text/plain; charset=utf-8');

    my $transport = Email::Sender::Transport::SMTP->new({
        host => $Service::Email::SMTP_HOST,
        port => 25,
    });

   # sendmail($message, { transport => $transport });    
}

# Send cp1251 email
sub _sendHtmlEmail
{
    my ($to, $subject, $body) = @_;
        
    my $message = Email::Simple->create(
        header => [
            From    => $Service::Email::FROM_ADDRESS,
            To      => $to,
            Subject => $subject
        ],
        body => $body
    );
    $message->header_set("Content-Type" => 'text/html; charset=cp1251');
    
    my $transport = Email::Sender::Transport::SMTP->new({
        host => $Service::Email::SMTP_HOST,
        port => 25,
    });

   # sendmail($message, { transport => $transport });    
}

sub _addressInBlackList
{
    my $email = shift;
    foreach my $black (@Service::Email::BLACK_LIST)
    {
    	return 1 if($email =~ /\@$black/);
    }
}



1;