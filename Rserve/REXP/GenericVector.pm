# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)

# R Generic vector
# class Rserve_REXP_GenericVector extends Rserve_REXP_Vector 
package Rserve::REXP::GenericVector;

use strict;

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP::Vector;

our @ISA = qw( Rserve::REXP::Vector );
	
sub isList() { return Rserve::TRUE; }

sub getType() {
  return Rserve::XT_VECTOR;
}
	
1;
