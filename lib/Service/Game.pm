package Service::Game;
use strict;

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
        my $dao = DAO::Ticket->new();
        $dao->save($ticket);    
    }	
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

1;