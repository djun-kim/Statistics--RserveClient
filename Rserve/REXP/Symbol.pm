# * Rserve client for Perl
# * @author Djun Kim
# * Based on Clément Turbelin's PHP client
# * Licensed under GPL v2 or at your option v3

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# *
# * Developed using code from Simple Rserve client for PHP by Simon
# * Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
# * v0.6.2) developed by Simon Urbanek(c)

use warnings;
#use autodie;

# R symbol element
# class Rserve_REXP_Symbol extends Rserve_REXP {

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP;
use Rserve::Parser;

package Rserve::REXP::Symbol;

our @ISA = qw(Rserve::REXP);

sub new($$) {
    my $class = shift;
    my $self = {
        name => shift,
    };
    bless $self, $class;
    return $self;
}

sub getValue($) {
    my $self = shift;
    return $self->{name};
}

sub isSymbol() { return Rserve::TRUE; }

sub getType() {
    return Rserve::XT_SYM;
}

sub toHTML($) {
    my $self = shift;

    return
          '<div class="rexp xt_' . $self->getType() . '">' . "\n"
        . '<span class="typename">'
        . Rserve::Parser::xtName( $self->getType() )
        . '</span>' . "\n"
        . $self->{name}
        . $self->attrToHTML() . "\n"
        . '</div>';
}

sub __toString($) {
    my $self = shift;

    return '"' . $self->{name} . '"';
}

1;
