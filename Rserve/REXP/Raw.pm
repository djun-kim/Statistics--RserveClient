# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


#  R Raw data
# class Rserve_REXP_Raw extends Rserve_REXP {

use Rserve::REXP;
use Rserve::Parser;

package Rserve::REXP::Raw;
@ISA = (Rserve::REXP);

$value; #protected
	

# * return int
sub length() {
  return strlen($value);
}

sub setValue($value) {
  $this->value = $value;
}

sub getValue($value) {
  return $this->value;
}

sub  isRaw() { return Rserve::REXP::TRUE; }

sub getType() {
  return Rserve::Parser::XT_RAW;
}

sub toHTML() {
  $s = strlen($this->value) > 60 ? 
    substr($this->value,0,60).' (truncated)': 
      $this->value;
  return '<div class="rexp xt_'.
    $this->getType().
      '"> <span class="typename">raw</span><div class="value">'.
	$s.'</div>'.
	  $this->attrToHTML().'</div>';	
}

1;
