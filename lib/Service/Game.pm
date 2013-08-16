package Service::Game;
use strict;

use DAO::Ticket;
use DAO::Game;

my $log = Log::Log4perl->get_logger("Service::Game");
my $ticketDao = DAO::Ticket->new();
my $gameDao = DAO::Game->new();

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

sub addTicket
{
    my($self, $params) = @_;
    my $games = $params->{'games'};
    my @numbers = _validateNumbers($::optionsService->get('maxNumber'), @{$params->{'numbers'}});
    my $userId = $params->{'userId'};
    my $gamePrice = $params->{'gamePrice'} || $::optionsService->get('gamePrice');  
    if($games && @numbers && $userId && $gamePrice
        && $games > 0
        && ($games <= $::optionsService->get('maxGames'))
        && (scalar(@numbers) == $::optionsService->get('maxNumbers')))
    {
    	my $ticket = Data::Ticket->new();
    	$ticket->setNumbers(@numbers);
    	$ticket->setGames($games);
        $ticket->setGamesLeft($games);
    	$ticket->setUserId($userId);
    	$ticket->setCreated($::sql->now());
        $ticket->setGamePrice($gamePrice);
        $ticketDao->save($ticket);    
    }	
}

sub runGame
{
	my $self = shift;
	
    $log->info("Running Game.");
    	
	my $game = Data::Game->new();
	$game->setDate($::sql->now());
    
    my @luckyNumbers = $self->getLuckyNumbers();
    $game->setLuckyNumbers(@luckyNumbers);
    $log->info("Lucky numbers: @luckyNumbers");
    
    my @tickets = $ticketDao->findActive();
    $game->setTickets(scalar @tickets);
    $log->info("Tickets in Game: ", $game->getTickets());
        
    my %users = map { $_->getUserId() => 1 } @tickets;
    $game->setUsers(scalar (keys %users));
    $log->info("Users in Game: ", $game->getUsers());
    
    my $gamePrice = 0;
    foreach my $ticket (@tickets)
    {
        # update tickets "games left"
        my $gamesLeft = $ticket->getGamesLeft() - 1;
        $ticket->setGamesLeft($gamesLeft);
        $ticketDao->save($ticket);

        # calculate how many numbers were guesed for each tickets
        my $guessed = $self->calcGuessed($ticket, @luckyNumbers);
        
        # write a table ticket number, guessed numbers, user id, game id
        # $self->saveGameHistory($game, $ticket, $guessed);
        
        $gamePrice += $ticket->getGamePrice(); 
    }
    
    $game->setSum($gamePrice);
    $log->info("Game Price: ", $game->getSum());

    $gameDao->save($game);
    $log->info("Game #", $game->getId(), " from ", $game->getDate(), " was run.");
}

# Filter out numbers < 1 and > maxNumber
# Filter out duplicates
sub _validateNumbers
{
    my $maxNumber = shift;
    my @numbers;
    foreach my $num (@_)
    {
    	if(($num > 0) && ($num <= $maxNumber) && !_inArray($num, @numbers))
    	{
    		push(@numbers, $num);
    	}
    }
    return @numbers;
}

sub _inArray
{
	my $num = shift;
	foreach my $elem (@_)
	{
		return 1 if($num == $elem);
	}
	return 0;
}

sub getLuckyNumbers
{
    my $self = shift;
    my $max = $::optionsService->get('maxNumber');
    my $length = $::optionsService->get('maxNumbers');

    # Use Lucky Numbers from Options
    my @numbers = split(',', $::optionsService->get('luckyNumbers'));
    @numbers = _validateNumbers($max, @numbers);
    return @numbers if (scalar @numbers == $length);

    # Generate Lucky Numbers
    @numbers = ();
    my %addedNumbers;
    my @chars = (1..$max);
    foreach (1..$length)
    {
        my $num;
        do
        {
            $num = $chars[rand @chars];
        } until(!$addedNumbers{$num});
        $addedNumbers{$num} = $num;
    }
    @numbers = sort {$a<=>$b} keys %addedNumbers;
    
    return @numbers;
}

1;