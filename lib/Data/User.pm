package Data::User;

use strict;
use lib "..";
use parent 'Data::Abstract';

use DateTime;

my $salt = "SALT!"; 

sub getFields
{
	return
	(
	    'id' => { sql => 'id', key => '1' },
	    'firstName' => { sql => 'first_name', add => '1', update => '1' },
	    'lastName' => { sql => 'last_name', add => '1', update => '1' },
	    'login' => { sql => 'login', add => '1' },
	    'email' => { sql => 'email', add => '1', update => '1' },
	    'password' => { sql => 'password', add => '1', update => '1' },
        'referal' => { sql => 'referal', add => '1', update => '1' },
        'created' => { sql => 'created', add => '1' },
        'lastSeen' => { sql => 'last_seen', update => '1' }
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