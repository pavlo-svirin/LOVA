package Service::HtmlContent;
use strict;
use Switch;

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
	$lang = $lang || $self->{'lang'};
	$page = $page || $self->{'page'};
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

sub getContent
{
    my ( $self, $code, $count ) = @_;
    $code .= _getCodeSufixByCount($count);
    my $content = $self->{'dao'}->find({
        page => $self->{'page'},
        lang => $self->{'lang'},
        code => $code
    });
    if($content)
    {
        return $content->getContent();
    }
}

sub _getCodeSufixByCount
{
	my $count = shift;
	return unless (defined $count);
	$count = $count % 100;
    return "_5" if (($count >= 11) && ($count <= 19));

 	$count = $count % 10;
   	return "_1" if ($count == 1);
    return "_2" if (($count == 2) || ($count == 3) || ($count == 4));
    return "_5";
}

1;