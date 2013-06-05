#!/usr/bin/perl
use lib "/mnt/hgfs/Development/Perl/pemes/lova/code/lib/";
use options;
use global;
use Sirius::Common qw(debug);
use Service::Scheduler;

our $sql = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh = $sql->connect;

my $optionsService = new Service::Options();
my $userService = new Service::User();
my $schedulerService = new Service::Scheduler(
    userService => $userService,
    optionsService => $optionsService
);

$optionsService->load();
$schedulerService->runAccountSchedule();

$sql->disconnect();
