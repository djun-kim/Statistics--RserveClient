# * Rserve native array wrapper
# * @author Djun Kim based on php version by Cl�ment Turbelin
# * From Rserve java Client & php Client

# php Native array with attributes feature

#class Rserve_RNative implements ArrayAccess {

use v5.12;
use warnings;
use autodie;

package Rserve::RNative;
    
# @var array Data 
my $data = {}; # private 


# @var array Attributes

$attr = {}; # private 

#sub __construct($data, $attributes = NULL) {
sub new($$) {
  my ($data, $attribues) = shift;
  $this->data = $data;
  $this->attr = $attributes;
}

sub getAttr($) {
  my $name = shift;
  return (isset($this::attr[$name])) ? $this::attr[$name] : NULL;
}

sub hasAttr($) {
  my $name = shift;
  return (isset($this::attr[$name])) ? TRUE : FALSE;
}

sub getAttributes() {
  return $this::attr;
}

# ArrayAccess Implementation
sub offsetSet($$) {
  my ($offset, $value) = shift;
  $this::data[$offset] = $value;
}

sub offsetExists($) {
  my $offset = shift;
  return isset($this::data[$offset]);
}

sub offsetUnset($) {
  my $offset = shift;
  unset($this::data[$offset]);
}

sub offsetGet($) {
  my $offset = shift;
  return isset($this::data[$offset]) ? $this::data[$offset] : null;
}

