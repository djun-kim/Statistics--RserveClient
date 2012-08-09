use Rserve::REXP::Logical;

use Test::More tests => 3;

my $logical = new Rserve::REXP::Logical;

isa_ok($logical, 'Rserve::REXP::Logical', 'new returns an object that');
ok(!$logical->isExpression(), 'Logical is not an expression');
ok($logical->isLogical(), 'Logical is a logical');

done_testing($number_of_tests);
