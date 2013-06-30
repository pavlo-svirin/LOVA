package Service::Email;
use strict;

use Mail::Send;
use Email::Send;
use Email::Simple;

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
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    my $msg = Mail::Send->new();
    my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
    $msg->to($userName . "<" . $user->getEmail() . ">");
    $msg->subject('Регистрация на LOVA');
    $msg->add("From", 'LOVA <lova@pemes.net>');
    $msg->add("Content-Type", 'text/plain; charset=utf-8');
    my $fh = $msg->open('sendmail');
    print $fh "Здравствуйте.\n\n";
    print $fh "Вы получили это письмо, так как данный адрес электронной почты (e-mail) был использован при регистрации на сайте LoVa.su\n";
    print $fh "Если Вы не регистрировались на этом сайте, просто проигнорируйте это письмо и удалите его.\n";
    print $fh "Для подтверждения регистрации перейдите по следующей ссылке:\n";
    print $fh "http://lova.su/cab/" . $emailCode;
    print $fh "\n\n";
    print $fh "Информация с более полным содержанием о проекте находится по данной ссылке:\n";
    print $fh "http://kravec.org/mezhdunarodnyj-socialnyj-proekt-lova.html\n";
    print $fh "С уважением, LOVA!\n";
    $fh->close();
}

sub sendPasswordEmail
{
    my ($self, $user) = @_;
    my $userService = $self->{'userService'};
    
    $userService->loadProfile($user);
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    my $msg = Mail::Send->new();
    my $userName = $user->getFirstName() . ' ' . $user->getLastName(); 
    $msg->to($userName . "<" . $user->getEmail() . ">");
    $msg->subject('Восстановление пароля на LOVA');
    $msg->add("From", 'LOVA <lova@pemes.net>');
    $msg->add("Content-Type", 'text/plain; charset=utf-8');
    my $fh = $msg->open('sendmail');
    print $fh "Здравствуйте.\n\n";
    print $fh "Вы получили это письмо, так как данный адрес электронной почты (e-mail) был использован при регистрации на сайте LoVa.su\n";
    print $fh "Если Вы не регистрировались на этом сайте, просто проигнорируйте это письмо и удалите его.\n";
    print $fh "Для изменения пароля перейдите по следующей ссылке:\n";
    print $fh "http://lova.su/cab/" . $emailCode . "\n";
    print $fh "и поменяйте пароль в настройках Профиля.";
    print $fh "\n\n";
    print $fh "Спасибо.\n";
    $fh->close();
}

sub sendInviteEmail
{
    my ($self, $user) = @_;
    my $userService = $self->{'userService'};
    
    $userService->loadProfile($user);
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $userService->saveProfile($user);
    
    my $userName = $user->getFirstName(); 
    my $inviteName = $user->getReferal();
    my $invitee = $userService->findByLogin($user->getReferal());
    if($invitee)
    {
    	$inviteName = $invitee->getFirstName();
    }

    my $body = "Проект LOVA приветствует Вас, $userName!\n\n";
    $body .= "Ваш друг $inviteName зарегистрировал Вас в проекте lova.su, пройдите по этой ссылке для завершения регистрации:\n";
    $body .= "http://lova.su/cab/" . $emailCode;
    $body .= "\n";
    $body .= "Если Вы не знаете такого человека, или не хотите регистрироваться, просто проигнорируйте это сообщение.\n";
    $body .= "\n\n";
    $body .= "Информация с более полным содержанием о проекте находится по данной ссылке:\n";
    $body .= "http://kravec.org/mezhdunarodnyj-socialnyj-proekt-lova.html\n\n";
    $body .= "С уважением, LOVA!\n";
    
    my $to = $userName . "<" . $user->getEmail() . ">";
    my $subject = 'Регистрация на LOVA';
    $self->sendPlainEmail($to, $subject, $body);
}

sub sendToAllUsers
{
    my ($self, $subject, $body) = @_;
    my @users = $self->{'userService'}->findAll();
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
            From    => 'LOVA <lova@pemes.net>',
            To      => $to,
            Subject => $subject
        ],
        body => $body
    );
    $message->header_set("Content-Type" => 'text/plain; charset=utf-8');
    
    my $sender = Email::Send->new({mailer => 'SMTP'});
    $sender->mailer_args([Host => 'localhost']);
    $sender->send($message);
}

sub sendHtmlEmail
{
    my ($self, $to, $subject, $body) = @_;

    my $message = Email::Simple->create(
        header => [
            From    => 'LOVA <lova@pemes.net>',
            To      => $to,
            Subject => $subject
        ],
        body => $body
    );
    $message->header_set("Content-Type" => 'text/html; charset=utf-8');
    
    my $sender = Email::Send->new({mailer => 'SMTP'});
    $sender->mailer_args([Host => 'localhost']);
    $sender->send($message);
}

1;