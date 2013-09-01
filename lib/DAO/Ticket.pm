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

sub findWinnerTickets
{
    my ($self, $gameId, $guessed) = @_;
    
    my $table = $self->getTable();
    my $model = $self->getModel();
    
    my $query = "SELECT `tickets`.* FROM `game_tickets`";
    $query .= " JOIN `tickets` ON `game_tickets`.`ticket_id` = `tickets`.`id`";
    $query .= " WHERE `game_tickets`.`game_id` = ? AND `game_tickets`.`guessed` = ?";
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($gameId, $guessed);
    my @objects;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@objects, ${model}->new(%$ref));
    }
    
    return @objects;
}

1;