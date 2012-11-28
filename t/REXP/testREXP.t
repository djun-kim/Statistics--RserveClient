use warnings;
use autodie;

use Rserve::REXP;

use Test::More tests => 3;

my $rexp = new Rserve::REXP;

isa_ok( $rexp, 'Rserve::REXP', 'new returns an object that' );
ok( !$rexp->isExpression(), 'Rexp is not an expression' );

is( $rexp->toHTML(),
    "<div class='rexp xt_16'><span class='typename'>vector</span></div>\n",
    'HTML representation'
);

done_testing();
