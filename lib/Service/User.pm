package Service::User;
use strict;

my $table = "users";
my @systemProfileValues = ("like", "emailCode", "validateEmail", "showEmailWarning");

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

sub findByLoginOrEmail
{
    my $self = shift;
    my $values = shift;
    my $user;
    if($values->{"login"})
    {
        $user = $self->findByLogin($values->{"login"});
    }
    if(!$user && $values->{"email"})
    {
        $user = $self->findByEmail($values->{"email"});
    }
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

sub findExtJs
{
    my ($self, $config) = @_;

    my $page = int ($config->{'page'}) || 1;
    my $start = int ($config->{'start'}) || 0;
    my $limit = int ($config->{'limit'}) || 25;
    my $order = $::sql->handle->quote_identifier($config->{'sort'} || "created");
    my $direction = ($config->{'dir'} eq "ASC") ? "ASC" : "DESC";
    my @filters = $self->parseFilters($config);
    
    my $query = "SELECT `$table`.* FROM `$table`";
    if($config->{'sort'} eq 'meta.referals')
    {
    	$order = "meta.referals";
    	$query .= " left join ( 
                        select count(*) as referals, referal from users u 
                        join user_profile p on u.id = p.user_id
                        where p.name = 'validateEmail'
                        group by u.referal
                    ) meta on users.login = meta.referal";
    }
    $query .= " WHERE 1 = 1 ";
    for my $filter (@filters)
    {
        $query .= " AND `$table`." . $::sql->handle->quote_identifier($filter->{'field'});
        $query .= " LIKE ";
        $query .= $::sql->handle->quote("%" . $filter->{'value'} . "%");     	
    }
    $query .= " ORDER BY $order $direction ";
    $query .= " LIMIT ?, ?";

    Sirius::Common::debug($query);    
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute( $start, $limit);
    return () if($rv == 0E0);
    my @users;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@users, Data::User->new(%$ref));
    }
    return @users;
}

sub findActive
{
    my ($self) = @_;
    my $query = "SELECT `u`.* FROM `$table` u";
    $query .= " JOIN `user_profile` p ON `u`.`id` = `p`.`user_id` ";
    $query .= " WHERE `p`.`name` = 'validateEmail' ";
    $query .= " ORDER BY `u`.`created`";
    my $sth = $::sql->handle->prepare($query);
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
    my $sth = $::sql->handle->prepare("SELECT u.* FROM `$table` u JOIN `user_profile` p ON u.id = p.user_id WHERE `p`.`name` = 'emailCode' AND `p`.`value` = ?");
    my $rv = $sth->execute($emailCode);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $user = Data::User->new(%$ref);
    return $user;
}

sub findSubscribed
{
    my ($self) = @_;
    my $query = "SELECT `u`.* FROM `$table` `u` ";
    $query .= " LEFT JOIN `user_profile` p ON u.id = p.user_id AND p.name = 'subscribe'";
    $query .= " JOIN `user_profile` `pa` ON `u`.`id` = `pa`.`user_id` ";
    $query .= " WHERE ((`p`.`name` = 'subscribe' AND `p`.`value` = 'true') OR p.name IS NULL)";
    $query .= " AND `pa`.`name` = 'validateEmail' ";
    
    my $sth = $::sql->handle->prepare( $query );
    my $rv = $sth->execute();
    return () if($rv == 0E0);
    my @users;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@users, Data::User->new(%$ref));
    }
    return @users;
}

sub findCreatedInRange
{
    my ($self, $conf) = @_;
    
    my $from = $conf->{'from'} || '1970-01-01';
    $from .= ' 00:00:00';
    my $to = $conf->{'to'} || '2999-01-01';
    $to .= ' 23:59:59';
    
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `created` >= ? AND `created` <= ? ORDER BY `created`");
    my $rv = $sth->execute($from, $to);
    return () if($rv == 0E0);
    my @users;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@users, Data::User->new(%$ref));
    }
    return @users;
}

sub countAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT count(*) AS `total` FROM `$table`");
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub countExtJs
{
    my ($self, $config) = @_;
    my @filters = $self->parseFilters($config);
    
    my $query = "SELECT count(*) AS `total` FROM `$table`";
    $query .= " WHERE 1 = 1 ";
    for my $filter (@filters)
    {
        $query .= " AND " . $::sql->handle->quote_identifier($filter->{'field'});
        $query .= " LIKE ";
        $query .= $::sql->handle->quote("%" . $filter->{'value'} . "%");        
    }

    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}


sub countActive
{
    my ($self) = @_;
    my $query = "SELECT count(`u`.`id`) AS `total` FROM `$table` `u`";
    $query .= " JOIN `user_profile` `p` ON `u`.`id` = `p`.`user_id` ";
    $query .= " WHERE `p`.`name` = 'validateEmail' ";
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'} + 3000;
}

sub countReferals
{
    my ($self, $user) = @_;
    my $query = "SELECT count(`u`.`id`) AS `total` FROM `$table` `u`";
    $query .= " JOIN `user_profile` `p` ON `u`.`id` = `p`.`user_id` ";
    $query .= " WHERE `p`.`name` = 'validateEmail' ";
    $query .= " AND `referal` = ? ";
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($user->getLogin());
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub countSubscribed
{
    my ($self) = @_;
    my $query = "SELECT count(`u`.`id`) FROM `$table` `u` ";
    $query .= " LEFT JOIN `user_profile` p ON u.id = p.user_id AND p.name = 'subscribe'";
    $query .= " JOIN `user_profile` `pa` ON `u`.`id` = `pa`.`user_id` ";
    $query .= " WHERE ((`p`.`name` = 'subscribe' AND `p`.`value` = 'true') OR p.name IS NULL)";
    $query .= " AND `pa`.`name` = 'validateEmail' ";
    
    my $sth = $::sql->handle->prepare( $query );
    my $rv = $sth->execute();
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

sub getProfileValueFlag
{
    my ($self, $name) = @_;
    if(grep {$_ eq $name} @systemProfileValues)
    {
    	return 1;
    }
    return 0;
}

sub loadProfile()
{
	my ($self, $user) = @_;

	# Create empty profile
    $user->getProfile();
	my $sth = $::sql->handle->prepare("SELECT `name`, `value` FROM `user_profile` WHERE `user_id` = ?");
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
            my $flag_id = $self->getProfileValueFlag($name);
            if($flag_id == 1) # system value
            {
            	$self->deleteProfile($user, $name);
            }    		
	        my $sth = $::sql->handle->prepare("INSERT INTO `user_profile` (`user_id`, `name`, `value`, `flag_id`) VALUES (?, ?, ?, ?)");
	        $sth->execute($user->getId(), $name, $profile->{$name}, $flag_id);
    	}
    }    
}

sub deleteUser
{
	my ($self, $user) = @_;
	$self->deleteAccount($user);
	$self->deleteProfile($user);
    my $sth = $::sql->handle->prepare("DELETE FROM `$table` WHERE `id` = ?");
    $sth->execute($user->getId());
}

sub deleteProfile()
{
    my ($self, $user, $name) = @_;
    if($name)
    {
        my $sth = $::sql->handle->prepare("DELETE FROM `user_profile` WHERE `user_id` = ? AND `name` = ?");
        $sth->execute($user->getId(), $name);
    }
    else
    {
        my $sth = $::sql->handle->prepare("DELETE FROM `user_profile` WHERE `flag_id` <> 1 AND `user_id` = ?");
        $sth->execute($user->getId());
    }
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
    my $fondReward = ($self->countActive() * $rateFond) || 0;
    foreach my $user ($self->findActive())
    {
    	$self->loadAccount($user);
        my $referalReward = ($self->countReferals($user) * $rateReferal) || 0;
        $user->getAccount()->{'fond'} = $user->getAccount()->{'fond'} + $fondReward;
        $user->getAccount()->{'referal'} = $user->getAccount()->{'referal'} + $referalReward;
        $self->saveAccount($user);     	
    }
}

sub parseFilters
{
    my ($self, $params) = @_;
    my @filters = ();
    for my $param (keys %$params)
    {
    	if($param =~ /filter\[(\d+)\]\[field\]/)
    	{
    		my $fid = $1;
    		$filters[$fid] = {
                field => $params->{$param},
                value => $params->{"filter[$fid][data][value]"},
                type => $params->{"filter[$fid][data][type]"},
    		};
    	}
    }
    return @filters;
}

1;