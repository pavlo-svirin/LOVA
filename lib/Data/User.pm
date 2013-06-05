package Data::User;
use strict;
use lib "..";
use parent 'Data::BaseObject';

my $salt = "SALT!"; 

sub getFields
{
	return
	(
	    'id' => 'id',
	    'firstName' => 'first_name',
	    'lastName' => 'last_name',
	    'login' => 'login',
	    'email' => 'email',
	    'password' => 'password',
        'referal' => 'referal',
        'created' => 'created',
        'lastSeen' => 'last_seen'
	)
};

sub setPassword
{
	my ($self, $password) = @_;
	if($password)
	{
		my $crypted = crypt($password, $salt);
		$self->SUPER::setPassword($crypted);
	}
}

sub checkPassword
{
    my ($self, $password) = @_;
    if($password)
    {
        my $crypted = crypt($password, $salt);
    	if($crypted eq $self->getPassword())
    	{
    		return 1;
    	}
    }
    return undef;
}

sub getProfile
{
	my ($self) = @_;
	if(!$self->getData()->{'profile'})
	{
		$self->getData()->{'profile'} = {};
	}
	return $self->getData()->{'profile'};
}

sub getAccount
{
    my ($self) = @_;
    if(!$self->getData()->{'account'})
    {
        $self->getData()->{'account'} = {};
    }
    return $self->getData()->{'account'};
}

sub getCreatedYear
{
    my ($self) = @_;
	if($self->getCreated() =~ /(\d{4})-\d{2}-\d{2}/)
	{
        return $1;
	}
}

sub getCreatedMonth
{
    my ($self) = @_;
    if($self->getCreated() =~ /(\d{4})-(\d{2})-\d{2}/)
    {
        return $2;
    }
}

sub getCreatedDay
{
    my ($self) = @_;
    if($self->getCreated() =~ /(\d{4})-(\d{2})-(\d{2})/)
    {
        return $3;
    }
}

sub wasCreatedThisYear
{
    my ($self) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year = $year + 1900;
    
    if($self->getCreatedYear() == $year)
    {
        return 1;
    }
}

sub wasCreatedThisMonth
{
    my ($self) = @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year = $year + 1900;
    $mon++;
    
    if(($self->getCreatedYear() == $year) && ($self->getCreatedMonth() == $mon))
    {
    	return 1;
    }
}

1;