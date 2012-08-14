use v5.12;
use warnings;
use autodie;

use Rserve::REXP::Null;

use Test::More tests => 3;

my $null = new Rserve::REXP::Null;

isa_ok($null, 'Rserve::REXP::Null', 'new returns an object that');
ok(!$null->isExpression(), 'Null is not an expression');
ok($null->isNull(), 'Null is a null');

done_testing();
