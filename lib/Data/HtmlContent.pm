package Data::HtmlContent;

use strict;
use lib "..";
use parent 'Data::BaseObject';

sub getFields
{
	return
	(
	    'id' => 'id',
	    'page' => 'page',
	    'code' => 'code',
	    'lang' => 'lang',
	    'type' => 'type',
	    'content' => 'content'
	)
};

1;