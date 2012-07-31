#!/usr/bin/env perl
#
#  Ugly Test for REXP creation
#  Work in progress...
#
#  Based on PHP tests for php Rserve client 
#

use Rserve;
use Rserve::Connection;
use Rserve::REXP::Integer;

use Data::Dumper;
use strict;

do 'config.pl';

#function testBinary($values, $type, $options = array(), $msg = '') {

sub testBinary(@) {
  my $argc = @_;

  print "$argc\n";
  my $values = shift;

  my $type = shift;
  my $options = ();
  my $msg = "";
  if ($argc == 3) {
    $options = shift;
  }
  elsif ($argc == 4) {
    $msg = shift;
  }

  print 'Test '.$type.' '.$msg."\n";

  my $cn = 'Rserve::REXP::'.$type;
  
  print "cn = $cn \n";

  my $r = new $cn();
  
  my $tt  = lc($type);
  
  if ( $r->isVector()) {
    if ($r -> isList() && @$options['named']) {
      $r->setValues($values, Rserve::TRUE);			
    } 
    else {
      $r->setValues($values);
    }
  } 
  else {
    $r->setValue($values);
  }

  my $bin = Rserve::Parser::createBinary($r);

  print "bin = ";
  print Dumper($bin);
  print "\n";

  print Dumper(Rserve::Parser::parseDebug($bin, 0));

  my $r2 = Rserve::Parser::parseREXP($bin, 0);
    print Dumper($r2);

  my $cn2 = get_class($r2);
  if ( strtolower($cn2) != strtolower($cn)) {
    print 'Differentes classes';
    return Rserve::FALSE;
  } 
  else {
    print 'Class Type ok';
  }
}

testBinary( [1,2,3], 'Integer'  );

testBinary([1.1,2.2,3.3], 'Double'  );

testBinary([Rserve::TRUE, Rserve::FALSE, Rserve::TRUE, []], 'Logical');
