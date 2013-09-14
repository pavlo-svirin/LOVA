#!/usr/bin/perl
use lib "/mnt/hgfs/Development/Perl/pemes/lova/code/lib/";
use options;
use global;

our $sql = Sirius::MySQL->new(host=>$MYSQL{'host'}, db=>$MYSQL{'base'}, user=>$MYSQL{'user'}, password=>$MYSQL{'pass'}, debug=>1);
my $dbh = $sql->connect;

our $userService = new Service::User();
our $optionsService = new Service::Options();
our $schedulerService = new Service::Scheduler();
our $emailService = new Service::Email();
our $gameService = new Service::Game();
our $ticketService = new Service::Ticket();

$optionsService->load();


$schedulerService->run();


$sql->disconnect();
