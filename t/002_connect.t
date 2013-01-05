# -*- perl -*-

# t/002_connect.t - check that we can connect to an Rserve server

use Test::More tests => 2;

use Statistics::RserveClient::Connection;

my $object = Statistics::RserveClient::Connection->new('localhost');
isnt ($object, undef, "Created a Connection object");
isa_ok ($object, 'Statistics::RserveClient::Connection');

