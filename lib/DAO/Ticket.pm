package DAO::Ticket;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "tickets"; }
sub getModel { return "Data::Ticket"; }

sub findActive
{
	my $self = shift;
    return $self->findSql({
        where => " AND `paid` IS NOT NULL AND `games_left` > 0"
    });
}

sub findNotPaid
{
    my $self = shift;
    return $self->findSql({
        where => " AND `paid` IS NULL AND `games_left` > 0"
    });
}

sub findExtJs
{
    my ($self, $params) = @_;
    my ($where, $order);

    $where .= " AND `created` >= " . $::sql->quote($params->{'from'} . " 00:00:00") if($params->{'from'}); 
    $where .= " AND `created` <= " . $::sql->quote($params->{'to'} . " 23:59:59") if($params->{'to'});
    $where .= " AND `paid` IS NOT NULL" if($params->{'paid'} || $params->{'active'});
    $where .= " AND `games_left` > 0" if($params->{'active'});
    return $self->findSql({
        where => $where,
        order => $order,
        start => $params->{'start'},
        limit => $params->{'limit'} 
    });
}


1;