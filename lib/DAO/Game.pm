package DAO::Game;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "games"; }
sub getModel { return "Data::Game"; }


sub findExtJs
{
    my ($self, $params) = @_;
    my ($where, $order);

    $where .= " AND `date` >= " . $::sql->quote($params->{'from'} . " 00:00:00") if($params->{'from'}); 
    $where .= " AND `date` <= " . $::sql->quote($params->{'to'} . " 23:59:59") if($params->{'to'});
    return $self->findSql({
        where => $where,
        order => $order,
        start => $params->{'start'},
        limit => $params->{'limit'} 
    });
}


1;