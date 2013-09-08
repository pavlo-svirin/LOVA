package Service::Email;
use strict;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP;
use Email::Simple;

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
    my $userService = $self->{'userService'};

    $userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    
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
    my $userService = $self->{'userService'};
    
    $userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    
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
    my $userService = $self->{'userService'};
    return if(_addressInBlackList($user));
    
    $userService->loadProfile($user);
    my $lang = $user->getProfile()->{'lang'} || 'ru';
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    
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
    
	$self->sendPlainEmail($to, $subject, $body);
}

sub sendToAllUsers
{
    my ($self, $subject, $body) = @_;
    my @users = $userDao->findAll();
    foreach my $user (@users)
    {
        my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
        my $email = $userName . "<" . $user->getEmail() . ">";
        $self->sendHtmlEmail($email, $subject, $body);
    }
}

sub sendToSubscribedUsers
{
    my ($self, $subject, $body) = @_;
    my @users = $self->{'userService'}->findSubscribed();
    foreach my $user (@users)
    {
        my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
        my $email = $userName . "<" . $user->getEmail() . ">";
        $self->sendHtmlEmail($email, $subject, $body);
    }
}

sub sendToRecipients
{
    my ($self, $subject, $body, $recipients) = @_;
	foreach my $email (split(',', $recipients))
	{
		$self->sendHtmlEmail($email, $subject, $body);
	}
}

sub sendPlainEmail
{
    my ($self, $to, $subject, $body) = @_;

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

    sendmail($message, { transport => $transport });    
}

# Send cp1251 email
sub sendHtmlEmail
{
    my ($self, $to, $subject, $body) = @_;
        
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

    sendmail($message, { transport => $transport });    
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