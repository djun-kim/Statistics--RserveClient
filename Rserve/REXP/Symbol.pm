# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


# R symbol element
# class Rserve_REXP_Symbol extends Rserve_REXP {

use Rserve;
use Rserve qw (:xt_types );

use  Rserve::REXP;
use  Rserve::Parser;

package Rserve::REXP::Symbol;
@ISA = (Rserve::REXP);
	
$name; #protected

sub setValue($value) {
  $this->name = $value;	
}

sub getValue() {
  return $this->name;
}

sub isSymbol() { return Rserve::REXP::TRUE; }

sub getType() {
  return Rserve::XT_SYM;
}

sub toHTML() {
  return '<div class="rexp xt_'.$this->getType().'"><span class="typename">'.Rserve::Parser::xtName($this->getType()).'</span>'.$this->name.$this->attrToHTML().'</div>';	
}

sub __toString() {
  return '"'.$this->name.'"';
}

1;
