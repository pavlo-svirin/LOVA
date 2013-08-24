package DAO::Ticket;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "tickets"; }
sub getModel { return "Data::Ticket"; }

sub findActive
{
	my ($self, $userId) = @_;
	my $where = " AND `paid` IS NOT NULL AND `games_left` > 0";
	$where .= " AND `user_id` = " . $::sql->quote($userId) if($userId);
    return $self->findSql({ where => $where });
}

sub findForCurrentGame
{
    my ($self, $edge) = @_;
    my $where = " AND `paid` IS NOT NULL AND `games_left` > 0";
    $where .= " AND unix_timestamp(`paid`) < " . $::sql->quote($edge);
    return $self->findSql({ where => $where });
}

sub findNotPaid
{
    my ($self, $userId) = @_;
    my $where = " AND `paid` IS NULL AND `games_left` > 0";
    $where .= " AND `user_id` = " . $::sql->quote($userId) if($userId);
    return $self->findSql({ where => $where });
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