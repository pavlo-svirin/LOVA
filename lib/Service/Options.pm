package Service::Options;
use strict;

# Настройки администратора
my $table = "options";

sub new
{
    my $proto = shift;                 # извлекаем имя класса или указатель на объект
    my $class = ref($proto) || $proto; # если указатель, то взять из него имя класса
    my $self  = {};
    # Приём данных из new(param=>value)
    my %params = @_;
    foreach (keys %params)
    {
        $self->{$_} = $params{$_};
    }
    bless($self, $class);              # гибкий вызов функции bless
    return $self;
}

sub load
{
  my ($self) = @_;
  my $sth = $::sql->handle->prepare("SELECT `name`, `value` FROM `$table`");
  my $rv = $sth->execute();
  while(my $ref = $sth->fetchrow_hashref())
  {
      $self->set($ref->{'name'}, $ref->{'value'});
  }
}

sub get
{
  my ($self, $name) = @_;
  return $self->{$name};
}

sub set
{
  my ($self, $name, $value) = @_;
  $self->{$name} = $value;
}

sub save
{
  my ($self) = @_;
  $::sql->handle->do("DELETE FROM `$table`");
  foreach(keys %$self)
  {
    my $sth = $::sql->handle->prepare("INSERT INTO `$table`(`name`, `value`) VALUES(?, ?)");
    my $rv = $sth->execute($_, $self->{$_});
  } 
}

sub getAllNames
{
  my ($self) = @_;
  return (keys %{$self});
}

1;