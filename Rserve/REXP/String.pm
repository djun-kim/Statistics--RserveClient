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

use v5.12;
use warnings;
use autodie;

# R character vector
# class Rserve_REXP_String extends Rserve_REXP_Vector {

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP::Vector;

package Rserve::REXP::String;
our @ISA = qw(Rserve::REXP::Vector);

sub new($) {
  my $class = shift;
  my $self = {
      value => undef,
  };
  bless $self, $class;
  return $self;
}

sub setValue($$) {
  my $self = shift;
  my $value = shift;

  $self->{value} = $value;
}

sub getValue($) {
  my $self = shift;
  return $self->{value};
}

sub isString() { return Rserve::TRUE; }

sub getType() {
    return Rserve::XT_STR;
}

sub toHTML($) {
  my $self = shift;
  return '<div class="rexp xt_' . $self->getType() . '">' . "\n"
      . '<span class="typename">'
      . Rserve::Parser::xtName($self->getType())
      . '</span>' . "\n"
      . $self->{value}
      . $self->attrToHTML() . "\n"
      . '</div>';
}

sub __toString($) {
  my $self = shift;
  return '"' . ($self->{value} or '') . '"';
}

1;

