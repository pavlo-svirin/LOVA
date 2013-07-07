package DAO::HtmlContent;
use strict;

my $table = "html_content";

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

sub findById
{
    my ($self, $id) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `id` = ?");
    my $rv = $sth->execute($id);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $tmpl = Data::HtmlContent->new(%$ref);
    return $tmpl;
}

sub findAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table`");
    my $rv = $sth->execute();
    return () if($rv == 0E0);
    my @objects;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@objects, Data::HtmlContent->new(%$ref));
    }
    return @objects;
}

sub findByCodeAndLang
{
    my ($self, $name, $lang) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `code` = ? AND `lang` = ?");
    my $rv = $sth->execute($name, $lang);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $object = Data::HtmlContent->new(%$ref);
    return $object;
}

sub delete
{
    my ($self, $object) = @_;
    my $sth = $::sql->handle->prepare("DELETE FROM `$table` WHERE `id` = ?");
    $sth->execute($object->getId());
}

sub save
{
    my ($self, $object) = @_;
    my @fields = ("code", "lang", "content");
    my @values;
    foreach my $field(@fields)
    {
        push (@values, $object->get($field));
    }
    
    if($object->getId())
    {
        my $fieldsWithToken = join(', ', map {"`$_` = ? "} @fields);
        # TODO-VZ: add debug message
        my $sth = $::sql->handle->prepare("UPDATE `$table` SET $fieldsWithToken WHERE `id` = ?");
        $sth->execute(@values, $object->getId());
    }
    else
    {
        my $fieldsList = join(', ', map {"`$_`"} @fields);
        my $tokensList = join(', ', map {"?"} @fields);
        my $sth = $::sql->handle->prepare("INSERT INTO `$table` ($fieldsList) VALUES ($tokensList)");
        $sth->execute(@values);
        $object->setId($::sql->handle->{'mysql_insertid'});
    }
}

1;