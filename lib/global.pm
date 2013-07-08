package global;
use strict;

use options;

use DBI();
use CGI qw(:standard);
use CGI::Session();
use CGI::Cookie;

use Template;

use JSON -convert_blessed_universally;

use Sirius::Common;
use Sirius::MySQL;

use Service::Options;
use Service::Scheduler;
use Service::User;
use Service::Email;

use DAO::Abstract;
use DAO::EmailTemplates;
use DAO::HtmlContent;

use Data::BaseObject;
use Data::User;
use Data::EmailTemplate;
use Data::HtmlContent;

1;