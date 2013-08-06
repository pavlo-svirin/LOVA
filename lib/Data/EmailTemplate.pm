package Data::EmailTemplate;

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
	    'subject' => 'subject',
	    'body' => 'body'
	)
};

sub setTemplateVars
{
    my ($self, $vars) = @_;
    $self->{'vars'} = $vars;
}

sub getSubject
{
    my ($self) = @_;
    my $subject = $self->get('subject');
    $subject = $self->proccessTemplateVars($subject);   
    return $subject; 	
}

sub getBody
{
    my ($self) = @_;
    my $body = $self->get('body');
    $body = $self->proccessTemplateVars($body);   
    return $body;    
}

sub proccessTemplateVars
{
    my ($self, $value) = @_;
    my $vars = $self->{'vars'};
    if($vars)
    {
    	foreach my $key (keys %$vars)
    	{
    		my $var = "\Q[% \E$key\Q %]\E";
    		my $val = $vars->{$key};
    		$value =~ s/$var/$val/g;
    	}
    }
	return $value;
}

1;