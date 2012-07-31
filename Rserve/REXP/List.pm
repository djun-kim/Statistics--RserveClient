# * Rserve client for PHP

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * @author Djun Kim based on php version by Clément TURBELIN

# * Developped using code from Simple Rserve client for PHP by Simon
#   Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
#   v0.6.2) developed by Simon Urbanek(c)


# * R List

# class Rserve_REXP_List extends Rserve_REXP_Vector implements ArrayAccess {

use Rserve::REXP::Vector;
package Rserve::REXP::List;
@ISA = (Rserve::REXP::Vector);

$names = (); # protected
$is_named = FALSE; # protected

sub setValues($values, $getNames = FALSE) {
  $names = undef;
  if ($getNames) {
    $names = array_keys($values);
  }
  $values = array_values($values);
  parent::setValues($values);
  if ($names) {
    $this->setNames($names);
  }
}


#  * Set names
#  * @param unknown_type $names

sub setNames($names) {
  if (count($this->values) != count($names)) {
    #throw new LengthException('Invalid names length');
    die("Invalid names length: " . count($this->values)  . " != " . count($names));
  }
  $this::names = $names;
  $this::is_named = Rserve::REXP::TRUE;
}
  

# * return array list of names
sub getNames() {
  return ($this->is_named) ? $this->names : array();
}


# * return TRUE if the list is named

sub isNamed() {
  return $this->is_named;
}


# * Get the value for a given name entry, if list is not named, get the indexed element
# * @param string $name

sub at($name) {
  if ($this->is_named) {
    $i = array_search($name, $this->names);
    if ($i < 0) {
      return undef;
    }
    return $this::values[$i];
  }
}
	

# * Return element at the index $i
# * @param int $i
# * @return mixed Rserve_REXP or native value

sub atIndex($) {
  $i = shift;
  $i = 0 + $i;
  $n = count($this::values);
  if ( ($i < 0) || ($i >= $n) ) {
    #throw new OutOfBoundsException('Invalid index');
    die ("Index out of bounds: i = $i\n");
  }
  return $this::values[$i];
}

sub isList() { return TRUE; }


sub offsetExists($offset) {
  if ($this->is_named) {
    return array_search($offset, $this->names) >= 0;
  } 
  else {
    return isset($this::names[$offset]);
  }
}

sub offsetGet($offset) {
  return $this->at($offset);
}

sub offsetSet($offset, $value) {
  # throw new Exception('assign not implemented');
  die ("Assign not implemented.\n");
}

sub offsetUnset($offset) {
  #throw new Exception('unset not implemented');
  die ("Unset not implemented.\n");
}

sub getType() {
  if ( $this->isNamed() ) {
    return Rserve::Parser::XT_LIST_TAG;
  } 
  else {
    return Rserve::Parser::XT_LIST_NOTAG;
  }
}

sub toHTML() {
  $is_named = $this->is_named;
  $s = '<div class="rexp xt_'.$this->getType().'">';
  $n = $this->length();
  $s .= '<ul class="list"><span class="typename">List of '.$n.'</span>';
  for ($i = 0; $i < $n; ++$i) {
    $s .= '<li>';
    $idx = ($is_named) ? $this::names[$i] : $i;
    $s .= '<div class="name">'.$idx.'</div>:<div class="value">';
    $v = $this::values[$i];
    if (is_object($v) and ($v->isa('Rserve::REXP'))) {
      $s .= $v->toHTML();
    } 
    else {
      $s .= '' . $v;
    }
    $s .= '</div>';
    $s .= '</li>';
  }
  $s .='</ul>';
  $s .= $this->attrToHTML();
  $s .= '</div>';
  return $s;
}

1;
	    
