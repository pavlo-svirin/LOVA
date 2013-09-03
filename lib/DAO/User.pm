package DAO::User;
use strict;
use lib "..";
use parent 'DAO::Abstract';

use Log::Log4perl;

my $log = Log::Log4perl->get_logger("DAO::User");

sub getTable { return "users"; }
sub getModel { return "Data::User"; }

sub countRegisteredUsers
{
	my ($self, $params) = @_;
	
    my $from = $params->{'from'} || '1970-01-01';
    $from .= ' 00:00:00';
    my $to = $params->{'to'} || '2999-01-01';
    $to .= ' 23:59:59';
    my $scale = $params->{'scale'} || 'day';
    
    my $table = $self->getTable();
    
    my $query = "SELECT UNIX_TIMESTAMP(`created`) AS created, count(*) AS `total` FROM `$table`";
    $query .= " WHERE `created` >= ? AND `created` <= ?";
  	$query .= " GROUP BY TO_DAYS(`created`)" if($scale eq 'day');
    $query .= " GROUP BY YEARWEEK (`created`)" if($scale eq 'week');
    $query .= " GROUP BY EXTRACT(YEAR_MONTH FROM `created`)" if($scale eq 'month');
    $query .= " GROUP BY YEAR(`created`)" if($scale eq 'year');
    $log->debug($query);
    
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($from, $to);
    my $result = {};
    while(my $ref = $sth->fetchrow_hashref())
    {
    	$result->{$ref->{'created'}} = $ref->{'total'};
    }
    return $result;
}

sub countActivatedUsers
{
    my ($self, $params) = @_;
    
    my $from = $params->{'from'} || '1970-01-01';
    $from .= ' 00:00:00';
    my $to = $params->{'to'} || '2999-01-01';
    $to .= ' 23:59:59';
    my $scale = $params->{'scale'} || 'day';
    
    my $table = $self->getTable();
    
    my $query = "SELECT `p`.`value`, count(*) AS `total` FROM `$table` u";
    $query .= " JOIN `user_profile` p ON `u`.`id` = `p`.`user_id`";
    $query .= " WHERE `u`.`created` >= ? AND `u`.`created` <= ?";
    $query .= " AND `p`.`name` = 'validateEmail'";
    $query .= " GROUP BY TO_DAYS(FROM_UNIXTIME(`p`.`value`))" if($scale eq 'day');
    $query .= " GROUP BY YEARWEEK (FROM_UNIXTIME(`p`.`value`))" if($scale eq 'week');
    $query .= " GROUP BY EXTRACT(YEAR_MONTH FROM FROM_UNIXTIME(`p`.`value`))" if($scale eq 'month');
    $query .= " GROUP BY YEAR(FROM_UNIXTIME(`p`.`value`))" if($scale eq 'year');
    $log->debug($query);
    
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($from, $to);
    my $result = {};
    while(my $ref = $sth->fetchrow_hashref())
    {
        $result->{$ref->{'value'}} = $ref->{'total'};
    }
    return $result;
}

sub countReferalUsers
{
    my ($self, $params) = @_;
    
    my $from = $params->{'from'} || '1970-01-01';
    $from .= ' 00:00:00';
    my $to = $params->{'to'} || '2999-01-01';
    $to .= ' 23:59:59';
    my $scale = $params->{'scale'} || 'day';
    
    my $table = $self->getTable();
    
    my $query = "SELECT UNIX_TIMESTAMP(`created`) AS created, count(*) AS `total` FROM `$table`";
    $query .= " WHERE `created` >= ? AND `created` <= ?";
    $query .= " AND `referal` IS NOT NULL";
    $query .= " GROUP BY TO_DAYS(`created`)" if($scale eq 'day');
    $query .= " GROUP BY YEARWEEK (`created`)" if($scale eq 'week');
    $query .= " GROUP BY EXTRACT(YEAR_MONTH FROM `created`)" if($scale eq 'month');
    $query .= " GROUP BY YEAR(`created`)" if($scale eq 'year');
    $log->debug($query);
    
       
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($from, $to);
    my $result = {};
    while(my $ref = $sth->fetchrow_hashref())
    {
        $result->{$ref->{'created'}} = $ref->{'total'};
    }
    return $result;
}

1;