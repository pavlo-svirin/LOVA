package DAO::EmailTemplates;
use strict;

my $table = "email_templates";

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
    my $tmpl = Data::EmailTemplate->new(%$ref);
    return $tmpl;
}

sub findAll
{
    my ($self) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table`");
    my $rv = $sth->execute();
    return () if($rv == 0E0);
    my @tmpls;
    while(my $ref = $sth->fetchrow_hashref())
    {
      push(@tmpls, Data::EmailTemplate->new(%$ref));
    }
    return @tmpls;
}

sub findByCodeAndLang
{
    my ($self, $name, $lang) = @_;
    my $sth = $::sql->handle->prepare("SELECT * FROM `$table` WHERE `code` = ? AND `lang` = ?");
    my $rv = $sth->execute($name, $lang);
    return undef if($rv == 0E0);
    my $ref = $sth->fetchrow_hashref();
    my $tmpl = Data::EmailTemplate->new(%$ref);
    return $tmpl;
}

sub delete
{
    my ($self, $tmpl) = @_;
    my $sth = $::sql->handle->prepare("DELETE FROM `$table` WHERE `id` = ?");
    $sth->execute($tmpl->getId());
}

sub save
{
    my ($self, $tmpl) = @_;
    my @fields = ("code", "lang", "subject", "body");
    my @values;
    foreach my $field(@fields)
    {
        push (@values, $tmpl->get($field));
    }
    
    if($tmpl->getId())
    {
        my $fieldsWithToken = join(', ', map {"`$_` = ? "} @fields);
        # TODO-VZ: add debug message
        my $sth = $::sql->handle->prepare("UPDATE `$table` SET $fieldsWithToken WHERE `id` = ?");
        $sth->execute(@values, $tmpl->getId());
    }
    else
    {
        my $fieldsList = join(', ', map {"`$_`"} @fields);
        my $tokensList = join(', ', map {"?"} @fields);
        my $sth = $::sql->handle->prepare("INSERT INTO `$table` ($fieldsList) VALUES ($tokensList)");
        $sth->execute(@values);
        $tmpl->setId($::sql->handle->{'mysql_insertid'});
    }
}

1;