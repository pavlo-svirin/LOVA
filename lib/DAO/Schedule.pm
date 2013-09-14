package DAO::Schedule;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "schedules"; }
sub getModel { return "Data::Schedule"; }

sub findScheduledForNow
{
	my $self = shift;
    return $self->find({ schedule => 'NOW', status => 'SCHEDULED' });
}

1;