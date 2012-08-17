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

# R character vector
# class Rserve_REXP_String extends Rserve_REXP_Vector {

use Rserve;
use Rserve qw (:xt_types );

use  Rserve::REXP::Vector;

package Rserve::REXP::String;
our @ISA = qw(Rserve::REXP::Vector);

sub isString() { return Rserve::TRUE; }
	
sub getType() {
  return Rserve::XT_STR;
}
	
1;

