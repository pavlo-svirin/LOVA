package DAO::Game;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "games"; }
sub getModel { return "Data::Game"; }

1;