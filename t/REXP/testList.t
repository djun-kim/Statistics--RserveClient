use v5.12;
use warnings;
use autodie;

use Rserve::REXP::List;

use Test::More tests => 3;

my $lst = new Rserve::REXP::List;

isa_ok($lst, 'Rserve::REXP::List', 'new returns an object that');
ok(!$lst->isExpression(), 'List is not an expression');
ok($lst->isList(), 'List is an integer');

done_testing();
