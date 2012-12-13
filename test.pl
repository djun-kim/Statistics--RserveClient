#!/usr/bin/env perl
#
# This is a simple test script for the perl Rserve client.
# It establishes a connection to the Rserve server at 
# localhost on the standard port, sends a simple
# string to be evaluated (it prints 'Hello, world!')
# gets the result from the server and prints the result.

use strict;

use Rserve::Connection;

my $server = "localhost";

if (@ARGV > 0) {
    $server = @ARGV[0];
}

print "Opening connection to $server...\n";

my $cnx = new Rserve::Connection($server);

print "Established connection: $cnx.\n";

print "Checking if connection initialized... " . 
  (Rserve::Connection::initialized() ? "TRUE" : "FALSE") . "\n";

print "Sending string to R server for evaluation. Result is:\n";

my @result = $cnx->evalString("x='Hello, world!'; x");

print join "", @result;
print "\n";

