use v5.12;
use warnings;
use autodie;

use Rserve::REXP::Expression;
use Rserve::REXP::Double;

use Test::More tests => 3;

my $expr = new Rserve::REXP::Expression;

isa_ok($expr, 'Rserve::REXP::Expression', 'new returns an object that');
ok($expr->isExpression(), 'Expression is an expression');

my $dbl = new Rserve::REXP::Double;
ok(!$dbl->isExpression(), 'Double is not an expression');

done_testing();
