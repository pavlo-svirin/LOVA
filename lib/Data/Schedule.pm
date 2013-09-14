package Data::Schedule;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
	    'id' => { sql => 'id', key => '1' },
	    'status' => { sql => 'status', add => '1', update => '1' },
	    'schedule' => { sql => 'schedule', add => '1', update => '1' },
	    'module' => { sql => 'module', add => '1' },
        'method' => { sql => 'method', add => '1' },
	    'params' => { sql => 'params', add => '1', update => '1' },
        'description' => { sql => 'description', add => '1', update => '1' },
	    'lastStart' => { sql => 'last_start', update => '1' },
	    'lastEnd' => { sql => 'last_end', update => '1' },
        'lastStatus' => { sql => 'last_status', update => '1' },
        'lastResult' => { sql => 'last_result', update => '1' },
	)
};

1;
