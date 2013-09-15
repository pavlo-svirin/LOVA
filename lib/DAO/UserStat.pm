package DAO::UserStat;
use strict;
use lib "..";
use parent 'DAO::Abstract';
use Log::Log4perl;

my $log = Log::Log4perl->get_logger("DAO::UserStat");

sub getTable { return "user_stats"; }
sub getModel { return "Data::UserStat"; }

sub findByGameAndUser
{
	my ($self, $gameId, $userId) = @_;
	$log->debug($gameId,$userId);
	my $stat = $self->find({ game_id => $gameId, user_id => $userId }); 
    $log->debug($stat, $stat->getBonus());
	return $stat;  
}

1;