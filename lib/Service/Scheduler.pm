package Service::Scheduler;
use strict;
use Date::Calc qw(Add_Delta_Days Mktime Localtime);
use Log::Log4perl;
use Storable qw(thaw);
require DAO::Schedule;

my $log = Log::Log4perl->get_logger("Service::Scheduler");
my $scheduleDao = DAO::Schedule->new(); 

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

sub run 
{
	my $self = shift;
	my @tasks = $scheduleDao->findScheduledForNow();
    $log->info("Scheduler service is running. There are ", scalar @tasks, " tasks to run.");
    foreach my $task (@tasks) {
        $self->runTask($task);
    }
}

sub runTask
{
	my ($self, $task) = @_;
	$log->info("Running task: ", $task->getId());

    $task->setStatus('ACTIVE');
    $task->setLastStart($::sql->now());
    $scheduleDao->save($task);

    my $module = $task->getModule();
    my $method = $task->getMethod();
    my @params = @{ thaw($task->getParams()) };
    eval
    {
    	my $result = $module->$method(@params);;
        $task->setStatus('DONE');
        $task->setLastResult($result);           
    };
    if($@)
    {
        $log->error("Task <", $task->getId(), "> failed with error: ", $@);
        $task->setStatus('FAILED');           
    } 
    $task->setLastEnd($::sql->now());
    $scheduleDao->save($task);
	 
}

1;
