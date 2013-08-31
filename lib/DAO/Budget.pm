package DAO::Budget;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "budget"; }
sub getModel { return "Data::Budget"; }

1;