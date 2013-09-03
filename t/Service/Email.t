#!/usr/bin/perl

use lib "../../lib/";
use strict;
use warnings;
use Test::More;

# Verify module can be included via "use" pragma
BEGIN { use_ok('Service::Email') };

# Verify module can be included via "require" pragma
require_ok( 'Service::Email' );


is(Service::Email::_addressInBlackList('arhnt@mail.ru'), 1,   "_addressInBlackList: Address is in blacklist.");
is(Service::Email::_addressInBlackList('Arhnt <arhnt@bk.ru>'), 1,   "_addressInBlackList: Address is in blacklist.");
is(Service::Email::_addressInBlackList('arhnt+2@inbox.ru'), 1,   "_addressInBlackList: Address is in blacklist.");
is(Service::Email::_addressInBlackList('arhnt@maillist.ru'), '',   "_addressInBlackList: Address is not in blacklist.");



done_testing();