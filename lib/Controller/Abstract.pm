package Controller::Abstract;
use strict;
require Log::Log4perl;

my $log = Log::Log4perl->get_logger("Controller::Abstract");
my @generics = ('admin', 'ajax', 'ru', 'en', 'ua');

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
    $self->register();
    return $self;
}

sub getLinks { }
sub getName { }

sub register { 
	my ($self) = @_;
	foreach my $controller (keys %{$self->getLinks()}) 
	{
		if($::controllers->{$controller})
		{
			$log->error("Controller '", $controller, "' already registered.");
			die "Cannot register Controller '$controller'";
		}
		$::controllers->{$controller} = $self;
	}
}

sub _getByUrl
{
    my $url = shift;
    my @parts = _splitUrl($url);
    my $controller = $parts[0];
    return $::controllers->{$controller};
}

sub process
{
    my($self, $url, $params) = @_;
    my @parts = _splitUrl($url);
    my $controller = $parts[0];
    my $action = $parts[1];
    my $method = $self->getLinks()->{$controller}->{$action};
    if ($method)
    {
    	return $method->($url, $params);
    }
	else
	{
        $log->error("Method for '", $action, "' in Controller '", $controller, "' not found.");		
	}
}

sub _splitUrl
{
	my $url = shift;
    my @path = split('/', $url);
    my @parts = ();
    # remove generic parts
    foreach my $part (@path)
    {
        next unless($part);
        next if ($part =~ /^\s+$/);
        my $isGeneric;
        foreach my $generic (@generics)
        {
            $isGeneric = 1 if ($part eq $generic)
        }
        push(@parts, $part) unless ($isGeneric);
    }
    return @parts;
}

1;