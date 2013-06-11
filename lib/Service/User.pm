package Service::User;
use strict;

require Mail::Send;

my $table = "users";

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

sub findById
{
    my ($self, $id) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `id`= ?");
    my $rv = $sth->execute($id);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $user = Data::User->new(%$ref);
    return $user;
}

sub findByLogin
{
    my ($self, $login) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `login`= ?");
    my $rv = $sth->execute($login);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $user = Data::User->new(%$ref);
    return $user;
}

sub findByEmail
{
    my ($self, $email) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `email`= ?");
    my $rv = $sth->execute($email);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $user = Data::User->new(%$ref);
    return $user;
}

sub findAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` ORDER BY `created`");
    my $rv = $sth->execute();
    return () if($rv == 0E0);
    my @users;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@users, Data::User->new(%$ref));
    }
    return @users;
}

sub findByEmailCode
{
    my ($self, $emailCode) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` u JOIN `user_profile` p ON u.id = p.user_id WHERE `p`.`name` = 'emailCode' AND `p`.`value` = ?");
    my $rv = $sth->execute($emailCode);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $user = Data::User->new(%$ref);
    return $user;
}

sub countAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT count(*) AS `total` FROM `$table`");
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub countReferals
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("SELECT count(*) AS `total` FROM `$table` WHERE `referal` = ?");
    my $rv = $sth->execute($user->getLogin());
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub save
{
    my ($self, $user) = @_;
    my @fields = ("login", "email", "first_name", "last_name", "password", "referal");
    my @values;
    foreach my $field(@fields)
    {
    	push (@values, $user->get($field));
    }
    
    if($user->getId())
    {
        my $fieldsWithToken = join(', ', map {"`$_` = ? "} @fields);
        # TODO-VZ: add debug message
        my $sth = $::sql->handle->prepare("UPDATE `$table` SET $fieldsWithToken, `last_seen` = NOW() WHERE `id` = ?");
        $sth->execute(@values, $user->getId());
    }
    else
    {
        my $fieldsList = join(', ', map {"`$_`"} @fields);
        my $tokensList = join(', ', map {"?"} @fields);
        # TODO-VZ: add debug message
        my $sth = $::sql->handle->prepare("INSERT INTO `$table` ($fieldsList, `created`, `last_seen`) VALUES ($tokensList, NOW(), NOW())");
        $sth->execute(@values);
        $user->setId($::sql->handle->{'mysql_insertid'});
    }
}

sub createUserFromCgiParams
{
    my ($self, $params) = @_;
    my $user = Data::User->new();
    $user->setFirstName($params->{'first_name'}) if($params->{'first_name'});
    $user->setLastName($params->{'last_name'}) if($params->{'last_name'});
    $user->setLogin($params->{'login'}) if($params->{'login'});
    $user->setEmail($params->{'email'}) if($params->{'email'});
    $user->setPassword($params->{'password'}) if($params->{'password'});
    $user->setReferal($params->{'referal'}) if($params->{'referal'});
    return $user;
}

sub validate
{
    my ($self, $user) = @_;
    my $result->{'success'} = 'true';

    # Validate required fields
    if (!$user->getEmail())
    {
    	$result->{'fields'}->{'email'} = 'Введите почту';
        $result->{'success'} = 'false';
    }
    if (!$user->getFirstName())
    {
        $result->{'fields'}->{'first_name'} = 'Введите имя';
        $result->{'success'} = 'false';
    }
    if (!$user->getLogin())
    {
        $result->{'fields'}->{'login'} = 'Введите ник';
        $result->{'success'} = 'false';
    }
    if (!$user->getPassword())
    {
        $result->{'fields'}->{'password'} = 'Введите пароль';
        $result->{'success'} = 'false';
    }
    unless  ($user->getLogin() =~ /^\w+$/)
    {
        $result->{'fields'}->{'login'} = 'Ник должен состоять из латинских букв и цифр';
        $result->{'success'} = 'false';
    }
    if($user->getReferal())
    {
        unless($self->findByLogin($user->getReferal()))
        {
            $result->{'fields'}->{'referal'} = 'Пользователь с таким ником не найден';
            $result->{'success'} = 'false';
        }
    }   
         
    if($result->{'success'} eq 'false ')
    {
    	return $result;
    }
    
    # Validate uniq keys
    my $emailUser = $self->findByEmail($user->getEmail()); 
    if($emailUser && ($emailUser->getId() != $user->getId()))
    {
        $result->{'fields'}->{'email'} = 'Такая почта уже зарегистрирована';
        $result->{'success'} = 'false';
    }
    
    my $loginUser = $self->findByLogin($user->getLogin()); 
    if($loginUser && ($loginUser->getId() != $user->getId()))
    {
    	
        $result->{'fields'}->{'login'} = 'Такой логин уже зарегистрирован';
        $result->{'success'} = 'false';
    }
        
    return $result; 
}

sub loadProfile()
{
	my ($self, $user) = @_;

	my $sth = $::sql->handle->prepare("SELECT * FROM `user_profile` WHERE `user_id` = ?");
    my $rv = $sth->execute($user->getId());
    while(my $ref = $sth->fetchrow_hashref())
    {
    	$user->getProfile()->{$ref->{'name'}} = $ref->{'value'};
    }
}

sub saveProfile()
{
    my ($self, $user) = @_;
    $self->deleteProfile($user);
    my $profile = $user->getProfile();
    foreach my $name (keys %$profile)
    {
    	my $value = $profile->{$name};
    	if($value)
    	{
	        my $sth = $::sql->handle->prepare("INSERT INTO `user_profile` (`user_id`, `name`, `value`) VALUES (?, ?, ?)");
	        $sth->execute($user->getId(), $name, $profile->{$name});
    	}
    	else
    	{
            my $sth = $::sql->handle->prepare("DELETE FROM `user_profile` WHERE `user_id` = ? AND `name` = ?");
            $sth->execute($user->getId(), $name);
    	}
    }    
}

sub deleteProfile()
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("DELETE FROM `user_profile` WHERE `user_id` = ?");
    $sth->execute($user->getId());
}

sub loadAccount()
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `user_account` WHERE `user_id` = ?");
    my $rv = $sth->execute($user->getId());
    my $ref = $sth->fetchrow_hashref();
    
    $user->getAccount()->{'personal'} = $ref->{'personal'};
    $user->getAccount()->{'fond'} = $ref->{'fond'};
    $user->getAccount()->{'referal'} = $ref->{'referal'};
}

sub saveAccount()
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `user_account` WHERE `user_id` = ?");
    my $rv = $sth->execute($user->getId());
    if($rv == 1)
    {
        $sth = $::sql->handle->prepare("UPDATE `user_account` SET `personal` = ?, `fond` = ?, `referal` = ? WHERE `user_id` = ?");
        $sth->execute(
            $user->getAccount()->{'personal'},
            $user->getAccount()->{'fond'},
            $user->getAccount()->{'referal'},
            $user->getId()
        );
    }
    else
    {
        $sth = $::sql->handle->prepare("INSERT INTO `user_account` (`user_id`, `personal`, `fond`, `referal`) VALUES (?, ?, ?, ?)");
        $sth->execute(
            $user->getId(),
            $user->getAccount()->{'personal'},
            $user->getAccount()->{'fond'},
            $user->getAccount()->{'referal'}
        );
    } 
}

sub deleteAccount()
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("DELETE FROM `user_account` WHERE `user_id` = ?");
    $sth->execute($user->getId());
}

sub runAccount()
{
    my ($self, $rateFond, $rateReferal) = @_;
    my $fondReward = ($self->countAll() * $rateFond) || 0;
    foreach my $user ($self->findAll())
    {
    	$self->loadAccount($user);
        my $referalReward = ($self->countReferals($user) * $rateReferal) || 0;
        $user->getAccount()->{'fond'} = $user->getAccount()->{'fond'} + $fondReward;
        $user->getAccount()->{'referal'} = $user->getAccount()->{'referal'} + $referalReward;
        $self->saveAccount($user);     	
    }
}

sub sendFirstEmail
{
    my ($self, $user) = @_;
    $self->loadProfile($user);
    my $emailCode = Sirius::Common::GenerateRandomString(32);
    $user->getProfile()->{'emailCode'} = $emailCode;
    $self->saveProfile($user);
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

1;