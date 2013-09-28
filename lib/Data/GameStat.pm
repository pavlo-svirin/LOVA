package Data::GameStat;

use strict;
use lib "..";
use parent 'Data::Abstract';

sub getFields
{
	return
	(
	    'id' =>  { sql => 'id', key => '1' },
        'gameId' =>  { sql => 'game_id', add => '1' },	    
	    'guessed' => { sql => 'guessed' },
        'lovaTickets' => { sql => 'lova_tickets' }
	)
};

sub getGuessed
{
	my ($self, $num) = @_;
	if($num)
	{
		$self->get('guessed')->{$num};
	}
	return $self->get('guessed');
}

# Get max count of guessed numbers
sub getMaxGuessed
{
    my $self = shift;
    my $guessed = $self->getGuessed();
    for my $num (sort { $b <=> $a } keys %$guessed)
    {
    	return $num if ($guessed->{$num}->{'tickets'});
    }
}

# Count of tickets by count of guessed numbers 
sub getTickets
{
    my ($self, $num) = @_;
    if($num)
    {
    	if($self->get('guessed')->{$num})
    	{
            return $self->get('guessed')->{$num}->{'tickets'};
    	}
    	return undef;
    }
    my $count = 0;
    foreach my $num (keys %{$self->get('guessed')})
    {
    	$count += $self->get('guessed')->{$num}->{'tickets'};
    }
    return $count;
}

# Return number of tickets with max guessed
sub getNumOfWinnerTickets
{
    my $self = shift;
    my $max = $self->getMaxGuessed();
    return 0 unless ($max);
    return $self->get('guessed')->{$max}->{'tickets'};
}

# Get number of tickets with min distance to lova number.
sub getNumOfLovaTickets
{
    my ($self, $num) = @_;
    if($self->get('guessed')->{$num})
    {
        return $self->get('guessed')->{$num}->{'lova_tickets'};
    }
    return undef;
}

1;