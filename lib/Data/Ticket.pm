package Data::Ticket;

use strict;
use lib "..";
use parent 'Data::Abstract';


sub getFields
{
	return
	(
	    'id' => { sql => 'id', key => '1' },
	    'userId' => { sql => 'user_id', add => '1' },
	    'numbers' => { sql => 'numbers', add => '1' },
	    'games' => { sql => 'games', add => '1' },
        'gamesLeft' => { sql => 'games_left', add => '1', update => '1' },
	    'created' => { sql => 'created', add => '1' },
	    'paid' => { sql => 'paid', update => '1' },
	    'gamePrice' => { sql => 'game_price', add => '1' },
	)
};

# Save array as sorted join list
sub setNumbers
{
	my ($self, @numbers) = @_;
	my $list = join(",", sort {$a <=> $b} @numbers);
	$self->set('numbers', $list);
}

# return join list as array
sub getNumbers
{
    my $self = shift;
    my $list = $self->get('numbers');
    return sort {$a <=> $b} split(",", $list);    	
}

sub getEncodedId
{
	my $self = shift;
	my $code = int($self->getId()) ^ int($self->getUserId());
	return sprintf("%o", $code);
}

sub _decodeId
{
	my ($code, $userId) = @_;
	my $id = oct($code);
	return $id ^ int($userId);
}

1;
