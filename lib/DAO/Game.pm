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
    $order .= " ORDER BY " . $::sql->quote_field($params->{'sort'}) if($params->{'sort'});
    $order .= " DESC" if($params->{'dir'} eq 'DESC');
    return $self->findSql({
        where => $where,
        order => $order,
        start => $params->{'start'},
        limit => $params->{'limit'} 
    });
}

sub countExtJs
{
    my ($self, $params) = @_;
    my $where;
    $where .= " AND `date` >= " . $::sql->quote($params->{'from'} . " 00:00:00") if($params->{'from'}); 
    $where .= " AND `date` <= " . $::sql->quote($params->{'to'} . " 23:59:59") if($params->{'to'});
    return $self->countSql({ where => $where });
}

sub findLast
{
	my $self = shift;
    return $self->findSql({
    	where => " AND `approved` IS NOT NULL",
    	order => "ORDER BY `id` DESC",
    	start => 0,
    	limit => 1
    })	
}

1;