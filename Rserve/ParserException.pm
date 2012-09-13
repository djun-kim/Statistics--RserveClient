# * Rserve client for Perl
# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * Based on rserve-php by Clément TURBELIN
# * @author Djun Kim
# * Licensed under# GPL v2 or at your option v3

# * Rserve::ParserException extends Rserve::Exception
# * @author Djun Kim

use v5.12;
use warnings;
use autodie;

package Rserve::ParserException;

use Rserve::Exception;
use strict;
our @ISA = qw(Rserve::Exception);    # inherits from Exception

sub new {
    my $class = shift;
    my $self  = Exception->new();
    bless $self, $class;
    return $self;
}

1;
