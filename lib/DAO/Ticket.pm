package DAO::Ticket;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "tickets"; }
sub getModel { return "Data::Ticket"; }

1;