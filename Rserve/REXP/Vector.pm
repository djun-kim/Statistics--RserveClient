# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek 

# * Licensed under GPL v2 or at your option 3v

# * This code is derived from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)

use Rserve;
use Rserve qw (:xt_types );

use Rserve::REXP;
use Rserve::Parser;

use Exporter;

# R Double vector
# class Rserve_REXP_Vector extends Rserve_REXP {
package Rserve::REXP::Vector;
our @ISA = ("Rserve::REXP", qw(Exporter));

use strict;
	
sub new() {
  my $class = shift;
  my $self = {
	      _values => (),
	     };
  bless $self, $class;
  return $self;
}

# Returns TRUE (1)
sub isVector() {
  return Rserve::TRUE;
}

# Returns the length of the instance vector
sub length() {
  my $self = shift;
  return defined($self->{_values}) ? (@{$self->{_values}}) : 0;
}

# Sets the value of the instance vector to the value of the given array reference
sub setValues($$) {
  my $self = shift;
  my $valuesref = shift;
  my @values = @$valuesref;
  my $sv = \@{$self->{_values}};
  @$sv = @values;
  return @{$self->{_values}};
}

# Gets the value of the instance vector
sub getValues($) {
  my $self = shift;
  return defined($self->{_values}) ? @{$self->{_values}} : ();
}

# * Get value 
# * @param unknown_type $index
sub at($) {
  my $self = shift;
  my $index = shift;
  return @{$self->{_values}}[$index];
}

# * Gets the type of this object
sub getType() {
  return Rserve::XT_VECTOR;
}

sub toHTML() {
  my $self = shift;
  my $s = "<div class='rexp vector xt_".$self->getType()."'>\n";
  my $n = $self->length();
  $s .= 
    '<span class="typename">'. Rserve::Parser::xtName($self->getType()). "</span>\n".
    "<span class='length'>$n</span>\n";
  $s .= "<div class='values'>\n";
  if ($n) {
    my $m = ($n > 20) ? 20 : $n;
    for (my $i = 0; $i < $m; ++$i) {
      my $v = @{$self->{_values}}[$i];
      if (ref($v) and ($v->isa('Rserve::REXP'))) {
	$v = $v->toHTML();
      }
      else {
	if ($self->isString()) {
	  $v = '"'.$v.'"';
	} 
	else {
	  $v = "".$v;
	}
      }
      # print "^$v\n";
      $s .= "<div class='value'>$v</div>\n";
    }
  }
  $s .= "</div>\n";
  $s .= $self->attrToHTML();
  $s .= '</div>';
  return $s;
}

1;
