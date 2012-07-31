# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)

use strict;

# R Double Factor
# class Rserve_REXP_Factor extends Rserve_REXP_Integer {
package Rserve::REXP::Factor;
our @ISA = qw (Rserve::REXP::Integer);

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP::Integer;
	
#protected $levels;
my @_levels;
	
sub isFactor() { return Rserve::TRUE; }

sub getLevels() {
  return @_levels;
}

sub setLevels($) {
  my @levels = shift;
  @_levels = @levels;
}

sub asCharacters() {
  my @r = array();
  foreach (@_levels) {
    push(@r, $_levels[$_]);
  }
  return @r;
}

sub getType() {
  return Rserve::XT_FACTOR;
}

1;
