package Data::HtmlContent;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
	    'id' =>  { sql => 'id', key => '1' },
	    'page' => { sql => 'page', add => '1', update => '1' },
	    'code' => { sql => 'code', add => '1', update => '1' },
	    'lang' => { sql => 'lang', add => '1', update => '1' },
	    'type' => { sql => 'type', add => '1', update => '1' },
	    'content' => { sql => 'content', add => '1', update => '1' }
	)
};

1;