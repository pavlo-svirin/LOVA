package DAO::Abstract;
use strict;
require Log::Log4perl;

my $log = Log::Log4perl->get_logger("DAO::Abstract");

sub new
{
    my $proto = shift;                 # извлекаем имя класса или указатель на объект
    my $class = ref($proto) || $proto; # если указатель, то взять из него имя класса
    my $self  = {};
    my %params = @_;                   # приём данных из new(param=>value)
    foreach (keys %params){
        $self->{$_} = $params{$_};
    }
    bless($self, $class);              # гибкий вызов функции bless
    return $self;
}

# ============ FIND METHODS ===================

sub find
{
    my ($self, $params, $order) = @_;
    my $table = $self->getTable();
    my $model = $self->getModel();
    
    my @values;
    my $query = "SELECT * FROM `$table` WHERE 1 = 1";
    foreach my $field (keys %$params)
    {
        $query .= " AND `$field` = ?";
        push(@values, $params->{$field});
    }
    if($order)
    {
    	$query .= " ORDER BY `$order`";
    }
    $log->trace("Find: ", $query);
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute(@values);
        
    my @objects;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@objects, ${model}->new(%$ref));
    }
    
    return wantarray ? @objects : $objects[0];
}

sub findSql
{
    my ($self, $params) = @_;
    my $table = $self->getTable();
    my $model = $self->getModel();
    my $where = $params->{'where'};
    my $order = $params->{'order'};
    my $start = $params->{'start'};
    my $limit = $params->{'limit'};
    my @values;
    my $query = "SELECT * FROM `$table` WHERE 1 = 1";
    $query .= " " . $where if($where);
    $query .= " " . $order if($order);
    if(defined $start && $limit)
    {
    	push(@values, $start, $limit);
        $query .= " LIMIT ?, ?" 
    }
    
    $log->trace("FindSql: ", $query);
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute(@values);
        
    my @objects;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@objects, ${model}->new(%$ref));
    }
    
    return wantarray ? @objects : $objects[0];
}


sub findById
{
    my ($self, $id) = @_;
    return $self->find({id => $id});    
}

sub findAll
{
    my ($self) = @_;
    return $self->find();    
}

sub findExtJs
{
    my ($self, $params) = @_;
    my ($where, $order);
    # TODO-VZ: add extjs filter processing
    $order .= " ORDER BY " . $::sql->quote_field($params->{'sort'}) if($params->{'sort'});
    $order .= " DESC" if($params->{'dir'} eq 'DESC');
    return $self->findSql({
        where => $where,
        order => $order,
        start => $params->{'start'},
        limit => $params->{'limit'} 
    });
}


# ============ COUNT METHODS ===================

# ============ CRUD METHODS ====================

sub delete
{
    my ($self, $object) = @_;
    my $table = $self->getTable();
    my $query = "DELETE FROM `$table` WHERE `id` = ?";
    $log->trace("Delete: ", $query);
    my $sth = $::sql->handle->prepare($query);
    $sth->execute($object->getId());
}

sub save
{
    my ($self, $object) = @_;
    
    if($object->getId())
    {
    	$self->update($object);
    }
    else
    {
    	$self->add($object);
    }
}

sub add
{
    my ($self, $object) = @_;
    my $table = $self->getTable();

    my @fields = $object->getSqlAddFields();
    my (@values, @fieldsList, @tokens);
    foreach my $field (@fields)
    {
        push (@values, $object->get($field));
        push (@fieldsList, "`$field`");
        push (@tokens, "?");
    }
    my $query = "INSERT INTO `$table` ( " . join(",", @fieldsList) . " ) VALUES ( " . join(",", @tokens) . " )";
    $log->trace("Add: ", $query);
    my $sth = $::sql->handle->prepare($query);
    $sth->execute(@values);
    $object->setId($::sql->handle->{'mysql_insertid'});
}

sub update
{
	my ($self, $object) = @_;
    my $table = $self->getTable();

    my @fields = $object->getSqlUpdateFields();
    my (@values, @fieldsList);
    foreach my $field (@fields)
    {
    	push (@fieldsList, "`$field` = ? ");
        push (@values, $object->get($field));
    }
	
    my $query = "UPDATE `$table` SET " . join(",", @fieldsList) . "WHERE `id` = ?";
    $log->trace("Update: ", $query);
    my $sth = $::sql->handle->prepare($query);
    $sth->execute(@values, $object->getId());
}

1;