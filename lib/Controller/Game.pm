package Controller::Game;
use strict;
use JSON;
use Log::Log4perl;

require DAO::Ticket;


my $log = Log::Log4perl->get_logger("Service::Game");
my $ticketDao = new DAO::Ticket();

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
    $self->init();    
    return $self;
}

sub init
{
	my $self = shift;
    $self->{'gameService'} = new Service::Game();
    $self->{'userService'} = new Service::User();
}

sub process 
{
    my($self, $url, $params) = @_;
    my $response = { 'type' => 'redirect', 'data' => '/cab/' };
    
    my $user = $self->{'userService'}->getCurrentUser();
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
    	
        $response->{'data'} = $self->payGame($params, $user); 
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
		$self->{'gameService'}->addTicket({userId => $user->getId(), games => $games, numbers => \@numbers});
	}
}

sub deleteTicket
{
}

sub payGame
{
    my($self, $params, $user) = @_;
    my $response = { success => JSON::false, message => "Ошбика обработки." };
    
    if (not $params->{'selectedAccounts'} =~ /acc/ )
    {
    	$response->{'message'} = "Выберите счет для оплаты."; 
    	return $response;
    }
    
    my @tickets = $ticketDao->findNotPaid($user->getId());
    if(scalar @tickets == 0)
    {
        $response->{'message'} = "Билеты для оплаты не найдены."; 
        return $response;
    }
    
    my $sum = $::gameService->calcTicketsSum(@tickets);
    
    my @accounts = map { lc }
                   map { $_ =~ s/acc//; $_ }
                   grep { /^[a-z]+$/i }
                   grep { /acc/ }
                   split(",", $params->{'selectedAccounts'});
    
    # find is user has sum on selected accounts
    $::userService->loadAccount($user);

    $log->info("User <", $user->getId(), "> is trying to buy ",
        scalar @tickets, " tickets for total sum: \$", $sum,
        " from accounts: ", join(", ", @accounts), ". His debit: ", join(" ", %{$user->getAccount()}));

    my $debit = 0;
    foreach my $account (@accounts)
    {
        $debit += $user->getAccount()->{$account};
    }
    $log->debug("User debit: ", $debit);
    if($debit < $sum)
    {
       $response->{'message'} = "На выбранных счетах недостаточная сумма для оплаты."; 
       return $response;
    }

    # save accounts stats to verify during transaction
    my %saved;
    foreach my $account (keys %{$user->getAccount()})
    {
    	$saved{$account} = $user->getAccount()->{$account};
    }
        
    # start transaction
    $::sql->handle->begin_work();
    eval
    {
        # if any of user accounts differs from beginning - throw error
        $::userService->loadAccount($user);
        foreach my $account (keys %{$user->getAccount()})
        {
            if($user->getAccount()->{$account} != $saved{$account})
            {
                die "Account $account has different value: " . $user->getAccount()->{$account};
            }
        } 
    	
	    foreach my $account (@accounts)
	    {
	    	last if($sum <= 0);
	    	my $credit = $user->getAccount()->{$account};
	    	if($credit < $sum)
	    	{
	    		$sum -= $credit;
	            $user->getAccount()->{$account} = 0;
	    	}
	    	else
	    	{
                $user->getAccount()->{$account} = $credit - $sum;
	    	}
	    }
	    $::userService->saveAccount($user);
	    
	    # save tickets stats
	    foreach my $ticket(@tickets) 
	    {
	    	$ticket->setPaid($::sql->now());
	    	$ticketDao->save($ticket);
	    }
	    
    	$::sql->handle->commit();
    };
    if($@)
    {
        $log->error("Payment was unsuccessful: ", $@);
        eval{ $::sql->handle->rollback(); };
        $response->{'message'} = "Произошла ошибка, обновите страницу и попробуйте ещё раз.";
        return $response;
    }
    $log->info("Payment was done successfuly.");
    $response->{'success'} = JSON::true;
    $response->{'message'} = "Оплата произведена успешно.";
    return $response;
}

1;
