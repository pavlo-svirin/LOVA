package options;
use strict;

use base 'Exporter';
our @EXPORT = qw( $URL $IP $DOMAIN %MYSQL %OPTIONS );
our @EXPORT_OK = qw ();

our $SID;
our $URL   = $ENV{'REQUEST_URI'};
our $IP    = $ENV{'REMOTE_ADDR'};
our $DOMAIN = $ENV{'HTTP_HOST'};

our %MYSQL;
$MYSQL{'host'}='localhost';
$MYSQL{'base'}='lova';
$MYSQL{'user'}='lova';
$MYSQL{'pass'}='lova';

our %OPTIONS;
$OPTIONS{'SMTP'} = 'localhost';
$OPTIONS{'FROM'} = 'LOVA <send.lova@pemes.net>';

$Sirius::Common::debugFile = '/tmp/loto.log';
$CGI::POST_MAX = 1024 * 100;

$Service::Email::SMTP_HOST = "mail.la.net.ua";
