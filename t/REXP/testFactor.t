use v5.12;
use warnings;
use autodie;

use Rserve::REXP::Factor;

use Test::More tests => 4;

my $fact = new Rserve::REXP::Factor;

isa_ok( $fact, 'Rserve::REXP::Factor', 'new returns an object that' );
ok( !$fact->isExpression(), 'Factor is not an expression' );
ok( $fact->isFactor(),      'Factor is a facotr' );
ok( $fact->isInteger(),     'Factor is not an integer' );

done_testing();
