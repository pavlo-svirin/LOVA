#!/usr/bin/perl

use lib "../../lib/";
use strict;
use warnings;
use Test::More;
use Data::Ticket;

# Verify module can be included via "use" pragma
BEGIN { use_ok('Service::Game') };

# Verify module can be included via "require" pragma
require_ok( 'Service::Game' );


is(Service::Game::_inArray(1, (1, 2, 3)), 1,   "_inArray: Value in array.");
is(Service::Game::_inArray(7, (1, 2, 3)), 0,   "_inArray: Value not in array.");


my $max = 30;
my @got = Service::Game::_validateNumbers($max, 1, 2, 3);
is_deeply(\@got, [1, 2, 3], "_validateNumbers: Normal flow.");

@got = Service::Game::_validateNumbers($max, 1, 2, 30, 31);
is_deeply(\@got, [1, 2, 30], "_validateNumbers: Filter max numbers.");

@got = Service::Game::_validateNumbers($max, 1, 2, 0, -1);
is_deeply(\@got, [1, 2], "_validateNumbers: Filter min numbers.");

@got = Service::Game::_validateNumbers($max, 1, 2, 30, 2);
is_deeply(\@got, [1, 2, 30], "_validateNumbers: Filter duplicates.");

@got = Service::Game::_validateNumbers($max, 1, 2, 30, 2, 0, 31, -1, 5);
is_deeply(\@got, [1, 2, 30, 5], "_validateNumbers: All casses.");


# Lova Distance tests
my $minLovaDistance = Service::Game::_calcMinLovaDistance(5);
is($minLovaDistance, -1, "_calcMinLovaDistance: Null tickets.");

$minLovaDistance = Service::Game::_calcMinLovaDistance(5,
    Data::Ticket->new(lova_number => 1), 
    Data::Ticket->new(lova_number => 5),    
    Data::Ticket->new(lova_number => 10)    
);
is($minLovaDistance, 0, "_calcMinLovaDistance: Lova Number guessed");

$minLovaDistance = Service::Game::_calcMinLovaDistance(5,
    Data::Ticket->new(lova_number => 4), 
    Data::Ticket->new(lova_number => 7),    
    Data::Ticket->new(lova_number => 10)    
);
is($minLovaDistance, 2, "_calcMinLovaDistance: Lova Number - Search up.");

$minLovaDistance = Service::Game::_calcMinLovaDistance(15,
    Data::Ticket->new(lova_number => 6), 
    Data::Ticket->new(lova_number => 7),    
    Data::Ticket->new(lova_number => 10)    
);
is($minLovaDistance, 91, "_calcMinLovaDistance: Lova Number - Search down.");

done_testing();