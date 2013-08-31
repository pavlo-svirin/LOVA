package Controller::Budget;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

require DAO::Budget;

my $log = Log::Log4perl->get_logger("Controller::Budget");
my $dao = new DAO::Budget();

sub getName { return 'Controller::Budget' };

sub getLinks
{
	my $self = shift;
    return {
        'budget' => {
            'load' => sub { $self->load( @_ ) },
        },
    }
}

sub load
{
    my($self, $url, $params) = @_;  
    my @objects = $dao->findExtJs($params);
    my $response->{'success'} = JSON::true;
    foreach my $obj (@objects)
    {
        my $jsonObj = $obj->getData();
        push(@{$response->{data}}, $jsonObj);
    }
    return { 'type' => 'ajax', 'data' => $response };   
}

1;
