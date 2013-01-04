use Statistics::RserveClient::Connection;

use Test::More tests => 3;

my $cnx = new_ok(
    'Statistics::RserveClient::Connection' => ['localhost'],
    'new local connection'
);

ok( $cnx->initialized(), 'connection is initialized' );

ok( $cnx->close_connection(), 'closing a connection' );

done_testing($number_of_tests);
