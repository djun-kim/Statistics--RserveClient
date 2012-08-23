# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


# R Language type vector

#class Rserve_REXP_Language extends Rserve_REXP_List {

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP::List;

package Rserve::REXP::Language;
@ISA = (Rserve::REXP::List);
        
sub isLanguage() { return Rserve::REXP::TRUE; }
        
sub getType() {
  return Rserve::XT_LANG;
}
        
1;
