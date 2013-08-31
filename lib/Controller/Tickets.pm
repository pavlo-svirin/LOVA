package Controller::Tickets;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

require DAO::Ticket;

my $log = Log::Log4perl->get_logger("Controller::Tickets");
my $ticketDao = new DAO::Ticket();

sub getName { return 'Controller::Tickets' };

sub getLinks
{
    return {
        'tickets' => {
            'add' => {},
            'delete' => {},
            'pay' => {}       
        },
    }
}

sub process 
{
    my($self, $url, $params) = @_;
    my $response = { 'type' => 'redirect', 'data' => '/cab/' };
    
    my $user = $::userService->getCurrentUser();
    return unless($user);
    
    if($url =~ /\/add\//)
    {
        $self->addTicket($params, $user);
    }
    elsif($url =~ /\/delete\//)
    {
        $self->deleteTicket($params, $user);
    }
    elsif($url =~ /\/pay\//)
    {
    	$response->{'type'} = 'ajax';
        $response->{'data'} = $self->pay($params, $user); 
    }
    return $response;
}

sub addTicket
{
    my($self, $params, $user) = @_;
 	my @numbers = split(",", $params->{'selected_lottery_numbers'});
	my $games = $params->{'games_count'};
	if(@numbers && $games)
	{
		$::ticketService->addTicket({userId => $user->getId(), games => $games, numbers => \@numbers});
	}
}

sub deleteTicket
{
}

sub pay
{
    my($self, $params, $user) = @_;
    my $response = { success => JSON::false, message => "Ошбика обработки." };
    
    if (not $params->{'selectedAccounts'} =~ /acc/ )
    {
    	$response->{'message'} = "Выберите счет для оплаты."; 
    	return $response;
    }
    
    my @accounts = map { lc }
                   map { $_ =~ s/acc//; $_ }
                   grep { /^[a-z]+$/i }
                   grep { /acc/ }
                   split(",", $params->{'selectedAccounts'});

    if (! @accounts )
    {
        $response->{'message'} = "Выберите счет для оплаты."; 
        return $response;
    }

    eval { $::ticketService->pay(@accounts); };
    if($@)
    {
        $response->{'message'} = $@;
        return $response;
    }
    
    $response->{'success'} = JSON::true;
    $response->{'message'} = "Оплата произведена успешно.";
    return $response;
}

1;
