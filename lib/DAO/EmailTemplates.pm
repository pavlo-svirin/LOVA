package DAO::EmailTemplates;
use strict;
use lib "..";
use parent 'DAO::Abstract';

sub getTable { return "email_templates"; }
sub getModel { return "Data::EmailTemplate"; }

sub findByCodeAndLang
{
    my ($self, $name, $lang) = @_;
    return $self->find({code => $name, lang => $lang});
}

1;