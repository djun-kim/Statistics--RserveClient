use Rserve::REXP::Symbol;

use Test::More tests => 3;

my $symbol = new Rserve::REXP::Symbol;

isa_ok($symbol, 'Rserve::REXP::Symbol', 'new returns an object that');
ok(!$symbol->isExpression(), 'Symbol is not an expression');
ok($symbol->isSymbol(), 'Symbol is a symbol');

done_testing($number_of_tests);
