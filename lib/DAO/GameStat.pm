package DAO::GameStat;
use strict;
use Log::Log4perl;

my $log = Log::Log4perl->get_logger("DAO::GameStat");

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

sub getTable { return "game_stats"; }
sub getModel { return "Data::GameStat"; }

# ============ FIND METHODS ===================

sub findByGameId
{
    my ($self, $gameId) = @_;
    my $table = $self->getTable();
    my $model = $self->getModel();
    my $query = "SELECT * FROM `$table` WHERE game_id = ?";
    
    my $sth = $::sql->handle->prepare($query);
    my $rv = $sth->execute($gameId);
    return undef if($rv == 0E0);
    my $guessed;
    while(my $ref = $sth->fetchrow_hashref())
    {
        $guessed->{$ref->{'guessed'}}->{'tickets'} = $ref->{'tickets'};
        $guessed->{$ref->{'guessed'}}->{'users'} = $ref->{'users'};
    }
    my $stat = ${model}->new();
    $stat->setGameId($gameId);
    $stat->setGuessed($guessed);
    $log->debug($gameId);
    $log->debug($stat->getGuessed());
    return $stat;  
}

sub save
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
      my $sth = $::sql->handle->prepare($query);
    $sth->execute(@values);
    $object->setId($::sql->handle->{'mysql_insertid'});
}


1;