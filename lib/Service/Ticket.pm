package Service::Ticket;
use strict;

require DAO::Ticket;
require Log::Log4perl;

my $log = Log::Log4perl->get_logger("Service::Ticket");
my $ticketDao = DAO::Ticket->new();

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

sub calcTicketsSum
{
	my ($self, @tickets) = @_;
	my $sum = 0;
    foreach my $ticket (@tickets)
    {
        $sum += $ticket->getGamePrice() * $ticket->getGamesLeft();
    }
	return $sum;
}

sub pay
{
    my ($self, @accounts) = @_;
	
    my $user = $::userService->getCurrentUser();
    die "Пользователь не авторизирован." unless($user); 
    
    my @tickets = $ticketDao->findNotPaid($user->getId());
    die "Билеты для оплаты не найдены." if(scalar @tickets == 0); 

    my $sum = $::ticketService->calcTicketsSum(@tickets);
    
    # find is user has sum on selected accounts
    $::userService->loadAccount($user);

    $log->info("User <", $user->getId(), "> is trying to buy ", scalar @tickets, " tickets.");
    $log->info("Total sum: \$", $sum);
    $log->info("Selected accounts: ", join(", ", @accounts));
    $log->info("Account stats: ", join(" ", %{$user->getAccount()}));

    my $userDebit = 0;
    foreach my $account (@accounts)
    {
        $userDebit += $user->getAccount()->{$account};
    }
    die "На выбранных счетах недостаточная сумма для оплаты." if($userDebit < $sum); 

    # save accounts stats to verify during transaction
    my %saved = map { $_ => $user->getAccount()->{$_} } keys %{$user->getAccount()};
        
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
                $log->error("Account ", $account, " was changed.",
                    ' Original:  $', $saved{$account},
                    ' New: $',  $user->getAccount()->{$account});
                die "Произошла ошибка, обновите страницу и попробуйте ещё раз.";
            }
        } 
        
        # bill Accounts
        foreach my $account (@accounts)
        {
            last if($sum <= 0);
            my $debit = $user->getAccount()->{$account};
            my $credit = ($debit < $sum) ? $debit : $sum;
            $user->getAccount()->{$account} = $debit - $credit;
            $sum -= $credit;
            $log->info('Took $', $credit, ' from ', $account);
            $log->info('$', $sum, " left to bill.");
        }
        $::userService->saveAccount($user);
        
        # save tickets stats
        foreach my $ticket (@tickets) 
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
        die "Произошла ошибка, обновите страницу и попробуйте ещё раз.";
    }
    $log->info("Payment was done successfuly.");
}

sub calcGuessed
{
    my ($self, $ticket, @luckyNumbers) = @_;
    my @ticketNumbers = $ticket->getNumbers();
    my $guessed = 0;
    foreach my $ticketNum (@ticketNumbers)
    {
        foreach my $winNum (@luckyNumbers)
        {
            if($ticketNum == $winNum)
            {
                $guessed++;
                last;
            }
        }
    }
    return $guessed;
}


1;