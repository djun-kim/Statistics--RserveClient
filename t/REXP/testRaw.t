use warnings;
use autodie;

use Rserve::REXP::Raw;

use Test::More tests => 3;

my $raw = new Rserve::REXP::Raw;

isa_ok( $raw, 'Rserve::REXP::Raw', 'new returns an object that' );
ok( !$raw->isExpression(), 'Raw is not an expression' );
ok( $raw->isRaw(),         'Raw is a raw' );

done_testing();
