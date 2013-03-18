use Statistics::RserveClient::Connection;

use Test::More tests => 2;

 SKIP: {
     eval {
	 my $object = Statistics::RserveClient::Connection->new('localhost');
     };
     skip "Looks like Rserve is not reachable.  Skipping test.", 2 if $@;
     
     my $cnx = new_ok(
	 'Statistics::RserveClient::Connection' => ['localhost'],
	 'new local connection'
	 );
     ok( $cnx->initialized(), 'connection is initialized' );
     ok( $cnx->close_connection(), 'closing a connection' );
}

done_testing($number_of_tests);

