use warnings;
use autodie;

use Rserve::REXP::GenericVector;

use Test::More tests => 3;

my $gvec = new Rserve::REXP::GenericVector;

isa_ok( $gvec, 'Rserve::REXP::GenericVector', 'new returns an object that' );
ok( $gvec->isList(),   'GenericVector is a list' );
ok( $gvec->isVector(), 'GenericVector is a vector' );

done_testing();
