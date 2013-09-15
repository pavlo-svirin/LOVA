package Data::UserStat;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
        'gameId' =>  { sql => 'game_id', add => 1 },	    
        'userId' =>  { sql => 'user_id', add => 1 },      
	    'tickets' => { sql => 'tickets', add => 1 },
        'bonus' => { sql => 'bonus', add => 1 }
	)
};


1;