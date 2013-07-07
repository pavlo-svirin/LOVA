package Data::User;

use strict;
use lib "..";
use parent 'Data::BaseObject';

use DateTime;

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

sub getCreatedByScale
{
    my ($self, $scale) = @_;
    $scale = $scale || "day";

    $self->getCreated() =~ /(\d{4})-(\d{2})-(\d{2})/;

    return DateTime->new( year => $1, month => $2, day => $3 )
        ->truncate( to => $scale )
        ->ymd('-');
	
}

sub getActivatedByScale
{
    my ($self, $scale) = @_;
    $scale = $scale || "day";
    my $activation = $self->getProfile()->{'validateEmail'}; 
    return unless ($activation);

    return DateTime->from_epoch(epoch => $activation) 
        ->truncate( to => $scale )
        ->ymd('-');
    
}

sub getCreatedUnixTime
{
    my ($self) = @_;
    if($self->getCreated() =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
    {
        return DateTime->new( 
            year => $1,
            month => $2,
            day => $3,
            hour => $4,
            minute => $5,
            second => $6
        )->epoch();
    	
    }
}

1;