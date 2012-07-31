# * Rserve client for PHP
# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * $Revision$
# * @author Djun Kim based on php version by  Clément TURBELIN

# * Developed using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developped by Simon Urbanek(c)

# * R Expression wrapper
package Rserve::REXP;

use Rserve;

use Rserve;
use Rserve qw (:xt_types );


use strict;

use Exporter;

#  * List of attributes associated with the R object 
#  * @var Rserve_REXP_List

#protected $attr = NULL;
my $attr = undef;
	
sub new() {
  my $class = shift;
  my $self = {
	      _attr => (),
	     };
  bless $self, $class;
  return $self;
}

#sub setAttributes(Rserve_REXP_List $attr) {
sub setAttributes($) {
  my $self = shift;
  my $attrref = shift;
  my @attr = @$attrref;
  @{$self->{_attr}} = @attr;
  return @{$self->{_attr}};
}

sub hasAttribute($) {
  my $self = shift;
  if( @{$self->{_attr}} ) {
    return Rserve::FALSE;
  }
}

sub getAttribute($) {
  my $self = shift;
  my $name = shift;
  if( @{$self->{_attr}} ) {
    return undef;
  }
  return @{$self->{_attr}}->at($name);
}

sub attr() {
  my $self = shift;
  return @{$self->{_attr}};
}

sub isVector() { return Rserve::FALSE; }
sub isInteger() { return Rserve::FALSE; }
sub isNumeric() { return Rserve::FALSE; }
sub isLogical() { return Rserve::FALSE; }
sub isString() { return Rserve::FALSE; }
sub isSymbol() { return Rserve::FALSE; }
sub isRaw() { return Rserve::FALSE; }
sub isList() { return Rserve::FALSE; }
sub isNull() { return Rserve::FALSE; }
sub isLanguage() { return Rserve::FALSE; }
sub isFactor() { return Rserve::FALSE; }
sub isExpression() { return Rserve::FALSE; }

sub toHTML() {
  my $self = shift;
  return "<div class='rexp xt_". $self->getType(). "'><span class='typename'>".
    Rserve::Parser::xtName($self->getType()).
	"</span>".$self->attrToHTML()."</div>\n";
}

#protected function attrToHTML() {
sub attrToHTML() {
  my $self = shift;
  if ($self->{_attr}) { 
    return "<div class='attributes'>". @{$self->{_attr}}->toHTML()."</div>";
  }
}

sub getType() {
  return "Rserve::XT_VECTOR";
}

1;
