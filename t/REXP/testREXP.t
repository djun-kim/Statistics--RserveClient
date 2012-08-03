use Rserve::REXP;

use Test::More tests => 3;

my $rexp = new Rserve::REXP;

isa_ok($rexp, 'Rserve::REXP', 'new returns an object that');
ok(!$rexp->isExpression(), 'Rexp is not an expression');

is($rexp->toHTML(),
   "<div class='rexp xt_Rserve::XT_VECTOR'><span class='typename'>null</span></div>\n",
   'HTML representation');


done_testing($number_of_tests);
