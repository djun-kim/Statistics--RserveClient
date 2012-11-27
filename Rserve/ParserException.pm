# * Rserve client for Perl
# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * Based on rserve-php by Clément TURBELIN
# * @author Djun Kim
# * Licensed under# GPL v2 or at your option v3

# * Rserve::ParserException extends Rserve::Exception
# * @author Djun Kim

use strict;
use warnings;
#use autodie;

package Rserve::ParserException;

use Rserve::Exception;

use Exporter;

our @ISA = qw(Exporter Rserve::Exception);    # inherits from Exception
our @EXPORT = qw( new );

sub new {
    my $class = shift;
    my $self  = Rserve::Exception->new();
    bless $self, $class;
    return $self;
}

1;
