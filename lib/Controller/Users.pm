package Controller::Users;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

require DAO::User;

my $log = Log::Log4perl->get_logger("Controller::Users");

sub getName { return 'Controller::Tickets' };

sub getLinks
{
	my $self = shift;
    return {
        'users' => {
            'list' => sub { $self->list( @_ ) },
            'load' => sub { $self->load( @_ ) },
            'save' => sub { $self->save( @_ ) },
            'delete' => sub { $self->delete( @_ ) },
            'chart' => sub { $self->chart( @_ ) }
        },
    }
}

# Load all users for Users store
sub list 
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::true;
    $response->{'total'} = $::userService->countExtJs($params);
    my @users = $::userService->findExtJs($params);
    foreach my $user (@users)
    {
        my $data = $user->getData();
        $data->{'meta'}->{'referals'} = $::userService->countReferals($user);
        push(@{$response->{data}}, $data);
    }
   return { type => 'ajax', data => $response};
}

# Load individual user for UserDetails store
sub load 
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::false;
    my $user = $::userService->findById($params->{'id'});
    if($user)
    {
        $::userService->loadProfile($user);
        $::userService->loadAccount($user);
        if($user->getProfile()->{'validateEmail'})
        {
            $user->getProfile()->{'validateEmail'} = JSON::true;
        }
        if($user->getProfile()->{'like'})
        {
            $user->getProfile()->{'like'} = JSON::true;
        }
        my $data =  $user->getData();
        $data->{'meta'}->{'referals'} = $::userService->countReferals($user);
        push(@{$response->{data}}, $data);
        $response->{'success'} = JSON::true;
    }
    return { type => 'ajax', data => $response};
}

sub save 
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::true; 
    my $user = $::userService->findById($params->{'id'});
    $::userService->loadProfile($user);
    $::userService->loadAccount($user);
    
    # verify login and email
    $user->setLogin($params->{'login'});
    $user->setEmail($params->{'email'});
    $user->setFirstName($params->{'first_name'});
    $user->setLastName($params->{'last_name'});
    $user->setPassword($params->{'password'}) if($params->{'password'});
    $user->setReferal($params->{'referal'});

    $user->getProfile()->{'skype'} = $params->{'profile.skype'};
    $user->getProfile()->{'phone'} = $params->{'profile.phone'};
    $user->getProfile()->{'country'} = $params->{'profile.country'};
    $user->getProfile()->{'lang'} = $params->{'profile.lang'};

    $user->getAccount()->{'personal'} = $params->{'account.personal'};
    $user->getAccount()->{'fond'} = $params->{'account.fond'};
    $user->getAccount()->{'referal'} = $params->{'account.referal'};
    $user->getAccount()->{'win'} = $params->{'account.win'};
    $user->getAccount()->{'bonus'} = $params->{'account.bonus'};
        
    $::userService->save($user);
    $::userService->saveProfile($user);
    $::userService->saveAccount($user);
    
    return { type => 'ajax' , data => $response};
}

# Delete user
sub delete 
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::false;
    my $user = $::userService->findById($params->{'id'});
    if($user)
    {
        $::userService->deleteUser($user);
        $response->{'success'} = JSON::true;
    }
    return { type => 'ajax', data => $response};
}

sub chart
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::true;
    my @stats = $::userService->calcChart($params);
    $response->{'data'} = \@stats;
	return { type => 'ajax', data => $response};
}

1;
