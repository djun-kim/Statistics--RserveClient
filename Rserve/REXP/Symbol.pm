# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


use v5.12;
use warnings;
use autodie;

# R symbol element
# class Rserve_REXP_Symbol extends Rserve_REXP {

use Rserve;
use Rserve qw (:xt_types );

use  Rserve::REXP;
use  Rserve::Parser;

package Rserve::REXP::Symbol;
our @ISA = qw(Rserve::REXP);
	
my $name; #protected

sub setValue($$) {
  my $self = shift;
  my $value = shift;
  
  $self->_value = $value;
}

sub getValue($) {
  my $self = shift;
  return $self->_value;
}

sub isSymbol() { return Rserve::TRUE; }

sub getType() {
  return Rserve::XT_SYM;
}

sub toHTML($) {
  my $self = shift;

  return '<div class="rexp xt_' . $self->getType() . 
      '"><span class="typename">' . 
      Rserve::Parser::xtName($self->getType()) .
      '</span>' . 
      $self->name . $self->attrToHTML() . '</div>';	
}

sub __toString($) {
  my $self = shift;

  return '"'.$self->name.'"';
}

1;
