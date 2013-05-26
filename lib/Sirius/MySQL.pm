package Sirius::MySQL;
use strict;
use base 'Exporter';
our @EXPORT = qw();


# Пакет работы с MySQL
# Пример инициализация $mysql = Sirius::MySQL->new(host=>'localhost', db=>'sirius_db', user=>'sirius_user', password=>'pass');
# Основные функции
# connect
# disconnect
# handle
# q, quote
# query, query_field
# count
# table_exist
# field_exist

sub new {
	my $proto = shift;											# извлекаем имя класса или указатель на объект
	my $class = ref($proto) || $proto;			# если указатель, то взять из него имя класса
	my $self  = {};
	my %params = @_;
	foreach (keys %params){
		$self->{'data'}->{$_} = $params{$_};	# приём данных из new(param=>value)
	}
	bless($self, $class);										# гибкий вызов функции bless

	return $self;
}

# Функция устаналивает (если указано два аргумента) или возвращает параметр (если указан один параметр)
sub param {
	my ($self,$param,$value) = @_;
	$self->{'data'}->{$param} = $value if(defined $value);
	return $self->{'data'}->{$param} if($param);
	return $self->{'data'};
}

sub connect {
	my $self = shift;

	my $dbh = DBI->connect("DBI:mysql:database=" . $self->param('db') . ";host=" . $self->param('host'), $self->param('user'), $self->param('password'), {'RaiseError' => 1});
	$dbh->do("SET NAMES 'utf8';");
	$dbh->do("SET `character_set_client` = 'utf8';");
	$dbh->do("SET `character_set_results` = 'utf8';");
	$dbh->do("SET `collation_connection` = 'utf8_general_ci';");
	$self->param('handle',$dbh);
	return $self->handle;
}

sub disconnect {
	my $self = shift;
	my $dbh = $self->handle;
	$dbh->disconnect();
}

sub handle {
	my $self = shift;
	return $self->param('handle');
}

# MySQL quote string $dbh->quote()
sub quote {
	my $self = shift;
	my $value = shift;
	return $self->handle->quote($value);
}
# Alias for "quote"
sub q {
	my $self = shift;
	$self->quote(@_);
}

# MySQL query for 1 field in table
# SELECT `(field)` FROM `(table)` (WHERE ...)
sub query_field {
	my $self = shift;
	my ($table, $field, $where) = @_;
	Sirius::Common::debug('MySQL.pm', 'query_field', "SELECT `$table`.`$field` FROM `$table` $where") if($self->param('debug'));
	return undef unless ($self->table_exist($table) || $self->field_exist($field));
	my $sth = $self->handle->prepare("SELECT `$table`.`$field` FROM `$table` $where");
	$sth->execute();
	my $ref = $sth->fetchrow_hashref();
	$sth->finish();
	Sirius::Common::debug('MySQL.pm', 'query_field', 'Result: ', $ref->{$field}) if($self->param('debug'));
	return $ref->{$field};
}
# Alias for query_field
sub query {
	my $self = shift;
	$self->query_field(@_);
}


sub table_exist {
	my $self = shift;
	my ($table) = @_;

	return undef unless ($table);

	my $sth = $self->handle->prepare("SHOW TABLES LIKE " . $self->quote($table));
	my $rv = $sth->execute();
	$sth->finish();
	($rv > 0) ? return $table : return undef;
}

sub field_exist {
	my $self = shift;
	my ($table, $field) = @_;

	Sirius::Common::debug('MySQL.pm', 'field_exist', "SHOW COLUMNS FROM `$table` LIKE " . $self->quote($field)) if($self->param('debug'));

	return undef unless ($table && $field);
	return undef unless ($self->table_exist($table));

	my $sth = $self->handle->prepare("SHOW COLUMNS FROM `$table` LIKE " . $self->quote($field));
	my $rv = $sth->execute();
	$sth->finish();
	($rv > 0) ? return $field : return undef;
}


sub count {
	my $self = shift;
	my ($table, $where) = @_;

	return undef unless ($self->table_exist($table));

	my $sth = $self->handle->prepare("SELECT COUNT(*) AS `count` FROM `$table` $where");
	$sth->execute();
	my $ref = $sth->fetchrow_hashref();
	$sth->finish();
	return $ref->{'count'};
}


1;
