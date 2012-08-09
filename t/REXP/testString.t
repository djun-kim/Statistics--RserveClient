use Rserve::REXP::String;

use Test::More tests => 3;

my $string = new Rserve::REXP::String;

isa_ok($string, 'Rserve::REXP::String', 'new returns an object that');
ok(!$string->isExpression(), 'String is not an expression');
ok($string->isString(), 'String is a string');

done_testing($number_of_tests);


