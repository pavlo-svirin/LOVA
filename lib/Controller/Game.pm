package Controller::Game;
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
    $self->init();    
    return $self;
}

sub init
{
	my $self = shift;
    $self->{'gameService'} = new Service::Game();
    $self->{'userService'} = new Service::User();
}

sub process 
{
    my($self, $url, $params) = @_;
    my $response = { 'status' => 'redirect', 'data' => '/cab/' };
    
    my $user = $self->{'userService'}->getCurrentUser();
    return unless($user);
    
    if($url =~ /\/add\//)
    {
        $self->addTicket($params, $user);
    }
    elsif($url =~ /\/delete\//)
    {
        $self->deleteTicket($params, $user);
    }
    elsif($url =~ /\/pay\//)
    {
        $response->{'status'} = 'html';
        $response->{'data'} = $self->payGameWindow($params, $user); 
    }
    return $response;
}

sub addTicket
{
    my($self, $params, $user) = @_;
 	my @numbers = split(",", $params->{'selected_lottery_numbers'});
	my $games = $params->{'games_count'};
	if(@numbers && $games)
	{
		$self->{'gameService'}->addTicket({userId => $user->getId(), games => $games, numbers => \@numbers});
	}
}

sub deleteTicket
{
}

sub payGameWindow
{
    my($self, $params, $user) = @_;
    my ($html, $vars);
    $::template->process("../tmpl/part/pay.tmpl", $vars, \$html);
    return $html;	
}

1;