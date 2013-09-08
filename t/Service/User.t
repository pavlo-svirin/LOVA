#!/usr/bin/perl

use lib "../../lib/";
use strict;
use warnings;
use Test::More;
use Test::MockObject::Extends;
use Data::User;
use DAO::User;


# Verify module can be included via "use" pragma
BEGIN { use_ok('Service::User') };

# Verify module can be included via "require" pragma
require_ok( 'Service::User' );

my $user = Data::User->new();
$user->setLogin('TEST');

my $mock = Test::MockObject->new();
$mock->fake_module(
    'DAO::User',
    findByLogin => sub { return $user},
);

our $optionsService = Test::MockObject->new();

my $service = Service::User->new();
$service = Test::MockObject::Extends->new( $service );
$service->set_true('loadAccount', 'saveAccount');


flushUserAccount();
mockRefPercents(0, 0);
$service->payReferal('test', ());
is($user->getAccount()->{'referal'}, 0, 'payReferal: 0% for all accounts.');

flushUserAccount();
mockRefPercents(0, 5);
$service->payReferal('test', ( fond => 1, personal => 0.2 ));
is($user->getAccount()->{'referal'}, 0.05, 'payReferal: 0% Personal, 5% Fond.');

flushUserAccount();
mockRefPercents(10, 5);
$service->payReferal('test', ( fond => 0, personal => 0.2 ));
is($user->getAccount()->{'referal'}, 0.02, 'payReferal: 10% Personal, 5% Fond, Fond was not billed.');

flushUserAccount();
mockRefPercents(10, 5);
$service->payReferal('test', ( fond => 0.39, personal => 0.11 ));
is($user->getAccount()->{'referal'}, 0.02, 'payReferal: Round down.');

flushUserAccount();
mockRefPercents(10, 5);
$service->payReferal('test', ( fond => 0.19, personal => 0.09 ));
is($user->getAccount()->{'referal'}, 0.00, 'payReferal: Below 0.01.');

done_testing();

sub flushUserAccount
{
	$user->getAccount()->{'referal'} = 0;
    $user->getAccount()->{'fond'} = 0;
}

sub mockRefPercents
{
	my ($personal, $fond) = @_;
	$optionsService->mock( 'get',
	   sub {
	       return  $personal if ($_[1] eq 'refPersonal');
	       return  $fond if ($_[1] eq 'refFond');
	   }
    );
}