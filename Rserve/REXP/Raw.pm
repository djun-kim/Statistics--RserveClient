# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Cl�ment TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


use v5.12;
use warnings;
use autodie;

#  R Raw data
# class Rserve_REXP_Raw extends Rserve_REXP {

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP;

package Rserve::REXP::Raw;
our @ISA = qw(Rserve::REXP);

my $_value; #protected
	

# * return int
sub length($) {
  my $self = shift;    
  return strlen($self->_value);
}

sub setValue($$) {
  my $self = shift;
  my $value = shift;
  
  $self->_value = $value;
}

sub getValue($) {
  my $self = shift;
  return $self->_value;
}

sub  isRaw() { return Rserve::TRUE; }

sub getType() {
  return Rserve::XT_RAW;
}

sub toHTML($) {
  my $self = shift;
  my $s = strlen($self->value) > 60 ? 
    substr($self->value,0,60).' (truncated)': 
      $self->value;
  return '<div class="rexp xt_'.
    $self->getType().
      '"> <span class="typename">raw</span><div class="value">'.
	$s.'</div>'.
	  $self->attrToHTML().'</div>';	
}

1;
