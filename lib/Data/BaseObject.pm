package Data::BaseObject;
use strict;

# Базовый объект в базе данных
our $AUTOLOAD;

sub new
{
    my $proto = shift;                 # извлекаем имя класса или указатель на объект
    my $class = ref($proto) || $proto; # если указатель, то взять из него имя класса
    my $self  = {};
    my %params = @_;                   # приём данных из new(param=>value)
    foreach (keys %params){
        $self->{'data'}->{$_} = $params{$_};
    }
    bless($self, $class);              # гибкий вызов функции bless
    return $self;
}

sub getFields
{
	return ();
}

sub get
{
    my ($self, $field) = @_;
    return $self->{'data'}->{$field};
}

sub set
{
    my ($self, $field, $value) = @_;
    $self->{'data'}->{$field} = $value;
}

sub AUTOLOAD
{
    my ($self) = @_;  
    my $name = $AUTOLOAD;
    return if $name =~ /^.*::[A-Z]+$/;
    $name =~ s/^.*:://;   # strip fully-qualified portion
    if($name =~ /^([gs]et)(\w+)$/)
    {
        my $fieldName = lcfirst($2);
        my %fields = $self->getFields();
        if($fields{$fieldName})
        {
        	if($1 eq 'get')
        	{
                return $self->get($fields{$fieldName});
        	}
        	else
        	{
        		$self->set($fields{$fieldName}, $_[1]);
        	}
        }
            
    }
}

sub getId()
{
    my ($self) = @_;  
	return $self->get('id');
}

sub setId()
{
    my ($self, $value) = @_;  
    return $self->set('id', $value);
}

1;