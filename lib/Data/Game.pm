package Data::Game;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
        'id' => { sql => 'id', key => '1' },
        'date' => { sql => 'date', add => '1' },        
        'schedule' => { sql => 'schedule', add => '1' },        
        'luckyNumbers' => { sql => 'lucky_numbers', add => '1' },
        'sum' => { sql => 'sum', add => '1' },
        'users' => { sql => 'users', add => '1' },
        'tickets' => { sql => 'tickets', add => '1' },
        'approved' => { sql => 'approved', update => '1' }
	)
};

# Save array as sorted join list
sub setLuckyNumbers
{
    my ($self, @numbers) = @_;
    my $list = join(",", sort {$a <=> $b} @numbers);
    $self->set('lucky_numbers', $list);
}

# return join list as array
sub getLuckyNumbers
{
    my $self = shift;
    my $list = $self->get('lucky_numbers');
    return sort {$a <=> $b} split(",", $list);      
}

1;