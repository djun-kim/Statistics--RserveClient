# -*- perl -*-

# t/002_connect.t - check that we can connect to an Rserve server

use Test::More tests => 2;

use Statistics::RserveClient::Connection;

SKIP: {
    eval {
	my $object = Statistics::RserveClient::Connection->new('localhost');
	if ( !ref ($object) || ! UNIVERSAL::can($object, 'can') ) {
	    die "Can't create a connection\n";
	}
    };
    skip "Looks like Rserve is not reachable.  Skipping test.", 2 if $@;

    isnt ($object, undef, "Created a Connection object");
    isa_ok ($object, 'Statistics::RserveClient::Connection');
}

