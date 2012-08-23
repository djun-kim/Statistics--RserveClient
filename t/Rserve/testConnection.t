use Rserve::Connection;

use Test::More tests => 3;

my $cnx = new_ok('Rserve::Connection' => ['localhost'],
                 'new local connection');

ok($cnx->initialized(), 'connection is initialized');

ok($cnx->close(), 'closing a connection');

done_testing($number_of_tests);
