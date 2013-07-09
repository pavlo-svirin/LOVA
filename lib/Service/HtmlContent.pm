package Service::HtmlContent;
use strict;

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

sub getContentForPage
{
	my ($self, $page, $lang) = @_;
	my @contents = $self->{'dao'}->find({
		page => $page,
		lang => $lang
	});
	my $result = {};
	foreach my $content (@contents)
	{
		my $code = $content->getCode();
		$result->{$code} = $content->getContent();
	}
	return $result;
}

1;