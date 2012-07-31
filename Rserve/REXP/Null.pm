# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


# R Null value

use Rserve::REXP;
use Rserve::Parser;

# class Rserve_REXP_Null extends Rserve_REXP {
package Rserve::REXP::Null;
@ISA = (Rserve::REXP);
	
sub isList() { return Rserve::REXP::TRUE; }
sub isNull() { return Rserve::REXP::TRUE; }

sub getType() {
  return Rserve::Parser::XT_NULL;
}

1;

