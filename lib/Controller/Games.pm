package Controller::Games;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

my $log = Log::Log4perl->get_logger("Controller::Games");
my $gameDao = new DAO::Game();
my $budgetDao = new DAO::Budget();

sub getName { return 'Controller::Games' };

sub getLinks
{
	my $self = shift;
	return {
        'game' => {
            'load' => sub { $self->load( @_ ) },
            'run' => sub { $self->run( @_ ) },
            'approve' => sub { $self->approve( @_ ) }		
        },
	}
}

sub load
{
    my($self, $url, $params) = @_;	
    my @games = $gameDao->findExtJs($params);
    my $response->{'success'} = JSON::true;
    foreach my $game (@games)
    {
        my $data = $game->getData();
        $data->{'budget'} = {};
        if($game->getApproved())
        {
        	my $budget = $budgetDao->find({game_id => $game->getId()});
            $data->{'budget'} = $budget->getData() if($budget);
        }
        push(@{$response->{data}}, $data);
    }
    return { 'type' => 'ajax', 'data' => $response };	
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
    my $response->{'success'} = JSON::true;
    
    my $budget = {
    	prize => $params->{'budgetPrize'} || 0,
        fond => $params->{'budgetFond'} || 0,
        gift => $params->{'budgetGiftTickets'} || 0,
        bonus => $params->{'budgetBonus'} || 0,
        costs => $params->{'budgetCosts'} || 0,
        profit => $params->{'budgetProfit'} || 0
    };
    eval { $::gameService->approve( $params->{'gameId'}, $budget ); };
    if($@)
    {
        $log->error($@);
        $response->{'success'} = JSON::false;
        $response->{'message'} = "Error during game approvement.";
    }
    return { 'type' => 'ajax', 'data' => $response };    
}

1;
