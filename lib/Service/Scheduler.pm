package Service::Scheduler;
use strict;
use Date::Calc qw(Add_Delta_Days Mktime Localtime);

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

sub runAccountSchedule
{
    my $self = shift;
    my $optionsService = $self->{'optionsService'};
    my $userService = $self->{'userService'};

    my $nextScheduleTime = $optionsService->get('nextAccountTime');
    if($nextScheduleTime < time)
    {
    	print "Time to make money!";
    	Sirius::Common::debug("[Scheduler]: currently is " . time);
    	Sirius::Common::debug("[Scheduler]: scheduled time is " . $nextScheduleTime);
        $userService->runAccount($optionsService->get('rateFond'), $optionsService->get('rateReferal'));
    }
    $nextScheduleTime = $self->calcNextAccountTime();
    if($nextScheduleTime != $optionsService->get('nextAccountTime'))
    {
        Sirius::Common::debug("[Scheduler]: Next scheduled time is " . $nextScheduleTime);
        $optionsService->set('nextAccountTime', $nextScheduleTime);
        $optionsService->save();
    }
}

sub calcNextAccountTime
{
    my ($self, $time) = @_;
    my $optionsService = $self->{'optionsService'};
    $time = $time || time;

    my @scheduledDays;
    push (@scheduledDays, 1) if($optionsService->get('scheduleMonday'));
    push (@scheduledDays, 2) if($optionsService->get('scheduleTuesday'));
    push (@scheduledDays, 3) if($optionsService->get('scheduleWednesday'));
    push (@scheduledDays, 4) if($optionsService->get('scheduleThursday'));
    push (@scheduledDays, 5) if($optionsService->get('scheduleFriday'));
    push (@scheduledDays, 6) if($optionsService->get('scheduleSaturday'));
    push (@scheduledDays, 7) if($optionsService->get('scheduleSunday'));
    
    Sirius::Common::debug("[Scheduler]: Scheduler options: " . @scheduledDays . ", time: " . $optionsService->get('scheduleTime'));
	my $runHour = 12;
    my $runMin = 0;
    if ($optionsService->get('scheduleTime') =~ /^(\d+)\:(\d+)$/)
    {
        $runHour = $1;
        $runMin = $2;
    }
    my $runTime = $runHour * 60 * 60 + $runMin * 60; # 12:00
    my ($year, $mon, $mday, $hour, $min, $sec, $yday, $wday, $isdst) = Localtime($time);

    my $currentTime = $hour * 60 * 60 + $min * 60 + $sec;
    my $nextDay;

    foreach my $day (@scheduledDays)
    {
        if(($wday == $day) and ($runTime > $currentTime))
        {
            # Today later
            return Mktime( $year, $mon, $mday, $runHour, $runMin, 0 );
        }
        if(!$nextDay && ($day > $wday) )
        {
            $nextDay = $day;
        }
    }

    # Day later this week
    if($nextDay)
    {
        my ($nYear, $nMonth, $nDay) = Add_Delta_Days($year, $mon, $mday, $nextDay - $wday);
        return Mktime( $nYear, $nMonth, $nDay, $runHour, $runMin, 0);
    }

    # Day on next week
    my ($nYear, $nMonth, $nDay) = Add_Delta_Days($year, $mon, $mday, 7 - $wday + $scheduledDays[0]);
    return Mktime( $nYear, $nMonth, $nDay, $runHour, $runMin, 0);
	
}

1;
