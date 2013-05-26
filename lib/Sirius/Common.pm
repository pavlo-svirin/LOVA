# Общие функции
package Sirius::Common;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(debug);
@EXPORT_OK = qw();


$Sirius::Common::debugFile ||= '/tmp/sirius.log';

sub new {
    my $proto = shift;                  # извлекаем имя класса или указатель на объект
    my $class = ref($proto) || $proto;  # если указатель, то взять из него имя класса
    my $self  = {};
    bless($self, $class);               # гибкий вызов функции bless
    return $self;
}


sub debug{
    open(my $logFile, ">>", $Sirius::Common::debugFile);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;
    my $timestamp = "[$year-$mon-$mday $hour:$min:$sec]";
    print $logFile "$timestamp: \t";
    foreach(@_){
        print $logFile "$_ ";
    }
    print $logFile "\n";
    close($logFile);
}

sub GenerateRandomString {
    my $str_length = shift || 6;
    my @chars=('a'..'z','A'..'Z','0'..'9');
    my $rnd_string;
    foreach (1..$str_length) { 
        $rnd_string .= $chars[rand @chars];
    }
    return $rnd_string;
}


1;