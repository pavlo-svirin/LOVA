package Data::Abstract;
use strict;
require Log::Log4perl;

# Базовый объект в базе данных
our $AUTOLOAD;

my $log = Log::Log4perl->get_logger("Data::Abstract");

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

sub getFields { };

sub getSqlAddFields
{
    my $self = shift;
    my %allFields = $self->getFields();
    my @fields;
    foreach my $field (keys %allFields)
    {
        if($allFields{$field}->{'add'})
        {
            push(@fields, $allFields{$field}->{'sql'});
        }
    }
    return @fields;
}

sub getSqlUpdateFields
{
	my $self = shift;
	my %allFields = $self->getFields();
	my @fields;
    foreach my $field (keys %allFields)
    {
    	if($allFields{$field}->{'update'})
    	{
    		push(@fields, $allFields{$field}->{'sql'});
    	}
    }
    return @fields;
}

sub getData
{
    my ($self) = @_;
	return $self->{'data'};
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
                return $self->get($fields{$fieldName}->{'sql'});
        	}
        	else
        	{
        		$self->set($fields{$fieldName}->{'sql'}, $_[1]);
        	}
        }
        else
        {
        	$log->warn("No such field: ", $fieldName);
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