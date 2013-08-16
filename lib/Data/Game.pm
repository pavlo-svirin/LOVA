package Data::Game;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
        'id' => { sql => 'id', key => '1' },
        'date' => { sql => 'date', add => '1' },        
        'luckyNumbers' => { sql => 'lucky_numbers', add => '1' },
        'sum' => { sql => 'sum', add => '1' },
        'users' => { sql => 'users', add => '1' },
        'tickets' => { sql => 'tickets', add => '1' }
	
	)
};

1;