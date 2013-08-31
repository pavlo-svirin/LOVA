package Data::Budget;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
        'gameId' => { sql => 'game_id', add => '1', key => '1' },
        'sum' => { sql => 'sum', add => '1' },        
        'prize' => { sql => 'prize', add => '1' },        
        'fond' => { sql => 'fond', add => '1' },
        'gift' => { sql => 'gift', add => '1' },
        'bonus' => { sql => 'bonus', add => '1' },
        'costs' => { sql => 'costs', add => '1' },
        'profit' => { sql => 'profit', add => '1' }
	)
};

1;