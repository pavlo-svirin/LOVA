package Data::HtmlContent;

use strict;
use lib "..";
use parent 'Data::BaseObject';

sub getFields
{
	return
	(
	    'id' => 'id',
	    'code' => 'code',
	    'lang' => 'lang',
	    'content' => 'content'
	)
};

1;