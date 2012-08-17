# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developed using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


use v5.12;
use warnings;
use autodie;

# R Double vector

# class Rserve_REXP_Logical extends Rserve_REXP_Vector {

use Rserve;
use Rserve qw (:xt_types );

use  Rserve::REXP::Vector;

package Rserve::REXP::Logical;
our @ISA = qw(Rserve::REXP::Vector);


sub isInteger() { return Rserve::TRUE; }
sub isNumeric() { return Rserve::TRUE; }
sub isLogical() { return Rserve::TRUE; }
	
sub getType() {
  return Rserve::XT_ARRAY_BOOL;
}
	
1;

