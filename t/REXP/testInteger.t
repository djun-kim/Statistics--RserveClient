use Rserve::REXP;
use Rserve::REXP::Integer;

use Test::More tests => 3;

my $int = new Rserve::REXP::Integer;

isa_ok($int, 'Rserve::REXP::Integer', 'new returns an object that');
ok(!$int->isExpression(), 'Integer is not an expression');
ok($int->isInteger(), 'Integer is an integer');

done_testing($number_of_tests);
