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

# wrapper for R Unknown type

#class Rserve_REXP_Unknown extends Rserve_REXP {

package Rserve::REXP::Unknown;
	
sub new($) {
 my $class = shift;
 my $type = shift;
 my $self = {
             unknowntype => $type,
            };
 bless $self, $class;
 return $self;
}

sub getUnknownType($) {
  my $this = shift;
  return $this->{unknowntype};
}

1;
