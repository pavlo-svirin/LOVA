package Data::HtmlContent;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
	    'id' =>  { sql => 'id', key => '1' },
	    'page' => { sql => 'page', updatable => '1' },
	    'code' => { sql => 'code', updatable => '1' },
	    'lang' => { sql => 'lang', updatable => '1' },
	    'type' => { sql => 'type', updatable => '1' },
	    'content' => { sql => 'content', updatable => '1' }
	)
};

1;