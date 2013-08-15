#!/usr/bin/perl

use lib "../../lib/";
use strict;
use warnings;
use Test::More;

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



done_testing();