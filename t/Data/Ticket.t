#!/usr/bin/perl

use lib "../../lib/";
use strict;
use warnings;
use Test::More;

# Verify module can be included via "use" pragma
BEGIN { use_ok('Data::Ticket') };

# Verify module can be included via "require" pragma
require_ok( 'Data::Ticket' );

my $userId = 25;

my $ticket = new Data::Ticket();
$ticket->setUserId($userId);

my $id = 0;
while($id < 5000) {
	$id += int(rand(100));
	$ticket->setId($id);
	my $encoded = $ticket->getEncodedId();
	is(Data::Ticket::_decodeId($encoded, $userId), $id, "Encode\\Decode: $id");
}

done_testing();

