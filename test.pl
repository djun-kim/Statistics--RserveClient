#!/usr/bin/env perl
#
# This is a simple test script for the perl Rserve client.
# It establishes a connection to the Rserve server at 
# localhost on the standard port, sends a simple
# string to be evaluated (it prints 'Hello, world!')
# gets the result from the server and prints the result.

use Rserve::Connection;

print "Opening connection...\n";
$cnx = new Rserve::Connection('localhost');
print "Established connection: $cnx.\n";

print "Initializing connection...\n";
Rserve::Connection->init();
print "Checing if connection initialized... " . 
  (Rserve::Connection::initialized() ? "TRUE" : "FALSE") . "\n";

print "Sending string to R server for evaluation. Result is:\n";

@result = $cnx->evalString("x='Hello, world!'; x");

print join "", @result;
print "\n";

