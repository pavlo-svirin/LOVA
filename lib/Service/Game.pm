package Service::Game;
use strict;
use Date::Calc qw( Add_Delta_Days Date_to_Time Gmtime );
use Log::Log4perl;


require DAO::Ticket;
require DAO::Game;
require DAO::Budget;
require Data::Budget;

my $log = Log::Log4perl->get_logger("Service::Game");
my $ticketDao = DAO::Ticket->new();
my $gameDao = DAO::Game->new();
my $budgetDao = DAO::Budget->new();

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

sub runGame
{
	my $self = shift;
	my @luckyNumbers = @_;
	
    $log->info("Running Game.");
    	
	my $game = Data::Game->new();
	$game->setDate($::sql->now());
    
    @luckyNumbers = $self->getLuckyNumbers() if(!@luckyNumbers);
    
    my $max = $::optionsService->get('maxNumber');
    my $length = $::optionsService->get('maxNumbers');
    @luckyNumbers = _validateNumbers($max, @luckyNumbers);
    if (scalar @luckyNumbers != $length)
    {
        $log->error("Lucky numbers size less than expected: ", @luckyNumbers, ", expected size: ", $length);
    	die("Счастливые числа некорретные");
    }
    
    $game->setLuckyNumbers(@luckyNumbers);
    $log->info("Lucky numbers: @luckyNumbers");
    
    my $gameScheduleTimestamp = $self->findClosestPreviousGames();
    my $gameScheduleDate = $::sql->utcTimestampToDate($gameScheduleTimestamp);
    $game->setSchedule($gameScheduleDate);
    
    my $buffer = $::optionsService->get('bufferTime') * 60;
    my $edgeTime = $gameScheduleTimestamp - $buffer;
    $log->info("Closest schedule ", $gameScheduleDate, " ($gameScheduleTimestamp)");
    $log->info("Buffer time: ", $::optionsService->get('bufferTime'), ' minutes');
    $log->info("Edge time: ", $::sql->utcTimestampToDate($edgeTime), " ($edgeTime)");
    
    my @tickets = $ticketDao->findForCurrentGame($edgeTime);
    $game->setTickets(scalar @tickets);
    $log->info("Tickets in Game: ", $game->getTickets());
        
    my %users = map { $_->getUserId() => 1 } @tickets;
    $game->setUsers(scalar (keys %users));
    $log->info("Users in Game: ", $game->getUsers());
    
    my $ticketsByGuessedNumbers;
    my $gamePrice = 0;
    
    # Run transaction
    $::sql->handle->begin_work();
    eval
    {
	    foreach my $ticket (@tickets)
	    {
	        # update tickets "games left"
	        my $gamesLeft = $ticket->getGamesLeft() - 1;
	        $ticket->setGamesLeft($gamesLeft);
	        $ticketDao->save($ticket);
	
	        # calculate how many numbers were guesed for each tickets
	        my $guessed = $::ticketService->calcGuessed($ticket, @luckyNumbers);
	        
	        $gamePrice += $ticket->getGamePrice(); 
	        push(@{$ticketsByGuessedNumbers->{$guessed}}, $ticket);        
	    }
	    
	    $game->setSum($gamePrice);
	    $log->info("Game Price: ", $game->getSum());
	
        $gameDao->save($game);
        $self->writeGameStat($game, $ticketsByGuessedNumbers);
        $log->info("Game #", $game->getId(), " from ", $game->getDate(), " was run.");
        $::sql->handle->commit();
    };
    if($@)
    {
    	$log->error("Game run was unsuccessful. Error was: ", $@);
    	eval{ $::sql->handle->rollback(); };
    	die("Ошибка проведения розыгрыша.");
    }
}

sub getLuckyNumbers
{
    my $self = shift;
    my $max = $::optionsService->get('maxNumber');
    my $length = $::optionsService->get('maxNumbers');

    # Use Lucky Numbers from Options
    my @numbers = split(',', $::optionsService->get('luckyNumbers'));
    return @numbers if(@numbers); 

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

sub writeGameStat
{
    my ($self, $game, $ticketsByGuessedNumbers) = @_;	
    foreach my $num (sort {$a <=> $b} keys %$ticketsByGuessedNumbers)
    {
    	my @tickets = @{$ticketsByGuessedNumbers->{$num}};
    	my %users;
    	foreach my $ticket (@tickets)
    	{
    		$log->debug($ticket);
    		$users{$ticket->getUserId()} = 1 if($ticket);
    	}
    	my $usersCount = scalar (keys %users);
        my $ticketsCount = scalar (@tickets);
        $log->info($num, " number: ", $usersCount, " users, ", $ticketsCount, " tickets");
        
        my $sth = $::sql->handle->prepare("INSERT INTO `game_stats` (`game_id`, `guessed`, `users`, `tickets`) VALUES (?, ?, ?, ?)");
        $sth->execute($game->getId(), $num, $usersCount, $ticketsCount);
        
        foreach my $ticket (@tickets)
        {
        	my $sth = $::sql->handle->prepare("INSERT INTO `game_tickets` (`game_id`, `ticket_id`, `guessed`) VALUES (?, ?, ?)");
            $sth->execute($game->getId(), $ticket->getId(), $num);
        }   	
    }
}

# Find earlier and following game schedule UTC timestamps
sub getSchedules
{
	my ($self, $count) = @_;
	
    my @scheduledDays;
    push (@scheduledDays, 1) if($::optionsService->get('scheduleMonday'));
    push (@scheduledDays, 2) if($::optionsService->get('scheduleTuesday'));
    push (@scheduledDays, 3) if($::optionsService->get('scheduleWednesday'));
    push (@scheduledDays, 4) if($::optionsService->get('scheduleThursday'));
    push (@scheduledDays, 5) if($::optionsService->get('scheduleFriday'));
    push (@scheduledDays, 6) if($::optionsService->get('scheduleSaturday'));
    push (@scheduledDays, 7) if($::optionsService->get('scheduleSunday'));

    my ($runHour, $runMin) = (12, 0); # default 12:00
    if ($::optionsService->get('scheduleTime') =~ /^(\d+)\:(\d+)$/)
    {
        $runHour = $1;
        $runMin = $2;
    }
  
    my $deltaDays = int((($count + 1) / scalar @scheduledDays) + 1) * 7;
    my $startTimestamp = time - $deltaDays * 24 * 60 * 60;
    my $endTimestamp = time + $deltaDays * 24 * 60 * 60;
    my $current = $startTimestamp;
    $log->debug("Start time: ", $::sql->utcTimestampToDate($startTimestamp), " ($startTimestamp)");
    $log->debug("End time: ", $::sql->utcTimestampToDate($endTimestamp), " ($endTimestamp)");
    
    my (@schedules);
    while($current < $endTimestamp)
    {
    	my ($year, $mon, $mday, $hour, $min, $sec, $yday, $wday, $isdst) = Gmtime($current);
    	# Is there a schedule for current day?
    	if(grep { /$wday/ } @scheduledDays)
    	{
            my $ts = Date_to_Time( $year, $mon, $mday, $runHour, $runMin, 0 );
            $log->debug("Found schedule: ", $::sql->utcTimestampToDate($ts), " ($ts)");
            push(@schedules, $ts); 
    	}
    	
    	# move to next day
    	$current += 24 * 60 * 60;
    }
    return @schedules;
}

sub findClosestPreviousGames
{
	my $self = shift;
	my @schedules = $self->getSchedules(1);
	my $closest = $schedules[0];
	foreach my $schedule (@schedules)
	{
		if (($schedule > $closest) && ($schedule < time))
		{
			$closest = $schedule;
		}
	}
	return $closest;
}

sub findNextGames
{
    my ($self, $count) = @_;
    $count = $count || 1;
    my @schedules = $self->getSchedules($count);

    my @closest;
    foreach my $schedule (@schedules)
    {
        if ($schedule > time)
        {
            my ($year, $mon, $mday, $hour, $min, $sec, $yday, $wday, $isdst) = Gmtime($schedule);
            my $nextGame = sprintf("%04d-%02d-%02d %02d:%02d", $year,$mon,$mday,$hour,$min);
            push(@closest, $nextGame);
        }
    }
    splice(@closest, $count);
    
    $log->debug("Next games: ", join(" ", @closest));
    return @closest;
}

sub approve
{
	my ($self, $id, $budgetParams) = @_;
	my $game = $gameDao->findById($id);
	die "Game by game id '$id' not found." if(!$game);
	die "Game '$id' already approved." if($game->getApproved());
	
    # Run transaction
    $::sql->handle->begin_work();
    eval
    {
        $game->setApproved($::sql->now());
        $gameDao->save($game);
        
        my $budget = $self->createBudget($game, $budgetParams);
        $budgetDao->save($budget);
        
        $log->info("Game #", $game->getId(), " from ", $game->getDate(), " was approved.");
        $::sql->handle->commit();
    };
    if($@)
    {
        $log->error("Game approve was unsuccessful. Error was: ", $@);
        eval{ $::sql->handle->rollback(); };
        die("Error during game approve.");
    }
}

sub createBudget
{
    my ($self, $game, $budgetParams) = @_;
    my $budget = new Data::Budget();
    $budget->setGameId($game->getId());
    $budget->setSum($game->getSum());
    $budget->setPrize(_calcBudget($game->getSum(), $budgetParams->{'prize'}));
    $budget->setFond(_calcBudget($game->getSum(), $budgetParams->{'fond'}));
    $budget->setTickets(_calcBudget($game->getSum(), $budgetParams->{'tickets'}));
    $budget->setBonus(_calcBudget($game->getSum(), $budgetParams->{'bonus'}));
    $budget->setCosts(_calcBudget($game->getSum(), $budgetParams->{'costs'}));
    $budget->setProfit(_calcBudget($game->getSum(), $budgetParams->{'profit'}));
	return $budget;
}

sub _calcBudget
{
	my ($sum, $percent) = @_;
	return 0 if (!$sum || !$percent);
	return sprintf("%.2f", $sum * $percent / 100);
}

1;