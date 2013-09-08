package Controller::Reports;
use strict;
use lib "..";
use parent 'Controller::Abstract';

use JSON;
use Log::Log4perl;

require DAO::User;
my $userDao = new DAO::User();
my $log = Log::Log4perl->get_logger("Controller::Reports");

sub getName { return 'Controller::Reports' };

sub getLinks
{
	my $self = shift;
    return {
        'reports' => {
            'referal' => sub { $self->referal( @_ ) },
        },
    }
}

# Referal reports
sub referal 
{
    my($self, $url, $params) = @_;

    my $user = $::userService->getCurrentUser();
    return { type => 'html', data => ""} unless ($user && $userDao->countReferals($user));
    
    my @referals = $userDao->findReferals($user);
    my $vars->{'referals'} = \@referals;
    my $response;
    $::template->process("../tmpl/part/report-stat.tmpl", $vars, \$response) || die "Template process failed: ", $::template->error(), "\n";
    
    return { type => 'html', data => $response};
}


1;
