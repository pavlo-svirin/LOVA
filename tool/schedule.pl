#!/usr/bin/perl
use lib "/mnt/hgfs/Development/Perl/pemes/lova/code/lib/";
use options;
use global;
use Sirius::Common qw(debug);

our $sql = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh = $sql->connect;

our $optionsService = new Service::Options();
our $userService = new Service::User();
our $schedulerService = new Service::Scheduler();
our $gameService = new Service::Game();
$optionsService->load();

# $schedulerService->runAccountSchedule();
$gameService->runGame();

$sql->disconnect();
