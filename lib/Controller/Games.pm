package Controller::Games;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

my $log = Log::Log4perl->get_logger("Controller::Games");

sub getLinks
{
	my $self = shift;
	return {
        'game' => {
            'run' => sub { $self->run( @_ ) },
            'approve' => sub { $self->approve( @_ ) }		
        },
	}
}

sub run
{
    my($self, $url, $params) = @_;
    my $response->{'success'} = JSON::true;
    my @numbers = split(',', $params->{'luckyNumbers'});
    eval { $::gameService->runGame(@numbers); };
    if($@)
    {
    	$log->error($@);
        $response->{'success'} = JSON::false;
        $response->{'message'} = "Error during game run.";
    }
    return { 'type' => 'ajax', 'data' => $response };
}

sub approve
{
    my($self, $url, $params) = @_;
    my $result->{'success'} = JSON::false;
    my $response = { 'type' => 'ajax', 'data' => $result };
    $log->info("Game approved.");
    return $response;    
}

1;
