package DAO::HtmlContent;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "html_content"; }
sub getModel { return "Data::HtmlContent"; }

1;