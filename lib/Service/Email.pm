package Service::Email;
use strict;

require Mail::Send;

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
    $msg->subject('Регистрация на LoVa');
    $msg->add("From", 'LoVa <lova@pemes.net>');
    $msg->add("Content-Type", 'text/plain; charset=utf-8');
    my $fh = $msg->open('sendmail');
    print $fh "Здравствуйте.\n\n";
    print $fh "Вы получили это письмо, так как данный адрес электронной почты (e-mail) был использован при регистрации на сайте LoVa.su\n";
    print $fh "Если Вы не регистрировались на этом сайте, просто проигнорируйте это письмо и удалите его.\n";
    print $fh "Для подтверждения регистрации перейдите по следующей ссылке:\n";
    print $fh "http://lova.su/cab/" . $emailCode;
    print $fh "\n\n";
    print $fh "Спасибо.\n";
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
    $msg->subject('Восстановление пароля на LoVa');
    $msg->add("From", 'LoVa <lova@pemes.net>');
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

sub sendHtmlEmail
{
    my ($self, $to, $subject, $body) = @_;
    my $msg = Mail::Send->new();
    $msg->add("From", 'LoVa <lova@pemes.net>');
    $msg->add("Content-Type", 'text/html; charset=utf-8');
    $msg->to($to);
    $msg->subject($subject);
    my $fh = $msg->open('sendmail');
    print $fh $body;
    $fh->close();
}

1;