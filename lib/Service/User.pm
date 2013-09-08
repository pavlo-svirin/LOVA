package Service::User;
use strict;
use DateTime;
use Log::Log4perl;

require DAO::User;

my $log = Log::Log4perl->get_logger("Service::User");

my $table = "users";
my @systemProfileValues = ("like", "emailCode", "validateEmail", "showEmailWarning");
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
    $query .= " JOIN `user_profile` p  ON `u`.id = `p`.`user_id`  AND `p`.`name`  = 'subscribe' AND `p`.`value` = 'true'";
    $query .= " JOIN `user_profile` pa ON `u`.id = `pa`.`user_id` AND `pa`.`name` = 'validateEmail'";
    
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

sub countAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT count(*) AS `total` FROM `$table`");
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub countAllExceptLatest
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT count(*) AS `total` FROM `$table` WHERE `created` < DATE_SUB(NOW(), INTERVAL 2 HOUR)");
    my $rv = $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    return $ref->{'total'};
}

sub countLatestInvitedUsers
{
    my $self = shift;
    my $conf = shift;
    my $interval = int($conf->{'interval'}) || 60; # minutes
    my $referal = $conf->{'referal'};
    my $query = "SELECT count(*) AS `total` FROM `$table`";
    $query .= " WHERE `login` IS NULL";
    $query .= " AND `referal` = ?";
    $query .= " AND `created` > DATE_SUB(NOW(), INTERVAL $interval MINUTE)";
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($referal);
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
        unless($userDao->findByLogin($user->getReferal()))
        {
            $result->{'fields'}->{'referal'} = 'Пользователь с таким ником не найден';
            $result->{'success'} = 'false';
        }
        if($user->getReferal() eq $user->getLogin())
        {
            $result->{'fields'}->{'referal'} = 'Нельзя использовать свой ник';
            $result->{'success'} = 'false';
        }
    }   
         
    if($result->{'success'} eq 'false ')
    {
    	return $result;
    }
    
    # Validate uniq keys
    my $emailUser = $userDao->findByEmail($user->getEmail()); 
    if($emailUser && ($emailUser->getId() != $user->getId()))
    {
        $result->{'fields'}->{'email'} = 'Такая почта уже зарегистрирована';
        $result->{'success'} = 'false';
    }
    
    my $loginUser = $userDao->findByLogin($user->getLogin()); 
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
    return unless($user);
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
    $userDao->deleteProfile($user);
    my $profile = $user->getProfile();
    foreach my $name (keys %$profile)
    {
    	my $value = $profile->{$name};
    	if($value)
    	{
            my $flag_id = $self->getProfileValueFlag($name);
            if($flag_id == 1) # system value
            {
            	$userDao->deleteProfile($user, $name);
            }    		
	        my $sth = $::sql->handle->prepare("INSERT INTO `user_profile` (`user_id`, `name`, `value`, `flag_id`) VALUES (?, ?, ?, ?)");
	        $sth->execute($user->getId(), $name, $profile->{$name}, $flag_id);
    	}
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
    $user->getAccount()->{'win'} = $ref->{'win'};
    $user->getAccount()->{'bonus'} = $ref->{'bonus'};
}

sub saveAccount()
{
    my ($self, $user) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `user_account` WHERE `user_id` = ?");
    my $rv = $sth->execute($user->getId());
    if($rv == 1)
    {
        $sth = $::sql->handle->prepare("UPDATE `user_account` SET `personal` = ?, `fond` = ?, `referal` = ?, `win` = ?, `bonus` = ? WHERE `user_id` = ?");
        $sth->execute(
            $user->getAccount()->{'personal'},
            $user->getAccount()->{'fond'},
            $user->getAccount()->{'referal'},
            $user->getAccount()->{'win'},            
            $user->getAccount()->{'bonus'},            
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

sub getCurrentUser
{
    my $self = shift;
	my %cookies = fetch CGI::Cookie;
	my $sid = ($cookies{'sid'}) ? $cookies{'sid'}->value : undef;
	return undef unless($sid);
	my $cgiSession = new CGI::Session("driver:MySQL;", $sid, {Handle=>$::sql->handle});
	my $userId = $cgiSession->param('userId');
	return undef unless($userId);
	return $userDao->findById($userId);
}

sub calcChart
{
    my($self, $params) = @_;
    
    my $registered = $userDao->countRegisteredUsers({
        from => $params->{'from'},
        to => $params->{'to'},
        scale => $params->{'scale'}
    });

    my $activated = $userDao->countActivatedUsers({
        from => $params->{'from'},
        to => $params->{'to'},
        scale => $params->{'scale'}
    });

    my $referals = $userDao->countReferalUsers({
        from => $params->{'from'},
        to => $params->{'to'},
        scale => $params->{'scale'}
    });
    
    my $all = {};
    for my $timestamp (keys %$registered)
    {
    	my $truncate = DateTime->from_epoch(epoch => $timestamp)->truncate(to => $params->{'scale'})->epoch();
        $all->{$truncate}->{'registered'} = $registered->{$timestamp}; 
    }
    for my $timestamp (keys %$activated)
    {
        my $truncate = DateTime->from_epoch(epoch => $timestamp)->truncate(to => $params->{'scale'})->epoch();
        $all->{$truncate}->{'activated'} = $activated->{$timestamp}; 
    }
    for my $timestamp (keys %$referals)
    {
        my $truncate = DateTime->from_epoch(epoch => $timestamp)->truncate(to => $params->{'scale'})->epoch();
        $all->{$truncate}->{'referals'} = $referals->{$timestamp}; 
    }
    
    my @result;
	for my $timestamp (sort {$a <=> $b} keys %$all)
	{
		my $date = DateTime->from_epoch(epoch => $timestamp)->ymd('-');
		push(@result, {
			'date' => $date,
			'registered' => int($all->{$timestamp}->{'registered'}),
            'activated' => int($all->{$timestamp}->{'activated'}),
            'referals' => int($all->{$timestamp}->{'referals'})
		});
	}
	return @result;
}

sub payReferal
{
    my ($self, $referal, %creditByAccounts) = @_;
    my $user = $userDao->findByLogin($referal);

    $self->loadAccount($user);
    if($::optionsService->get('refPersonal') && $creditByAccounts{'personal'})
    {
    	my $reward = int ($creditByAccounts{'personal'} * $::optionsService->get('refPersonal')) / 100;
    	if($reward >= 0.01)
    	{
            $user->getAccount()->{'referal'} += $reward;
            $log->info("User <", $user->getId(), '> get $', $reward, " from referal.");
    	}
    }

    if($::optionsService->get('refFond') && $creditByAccounts{'fond'})
    {
        my $reward = int ($creditByAccounts{'fond'} * $::optionsService->get('refFond')) / 100;
        if($reward >= 0.01)
        {
            $user->getAccount()->{'referal'} += $reward;
            $log->info("User <", $user->getId(), '> get $', $reward, " from referal.");
        }
    }
    $self->saveAccount($user);
}


1;