use v5.12;
use warnings;
use autodie;

use Rserve::REXP::Language;

use Test::More tests => 3;

my $lang = new Rserve::REXP::Language;

isa_ok($lang, 'Rserve::REXP::Language', 'new returns an object that');
ok(!$lang->isExpression(), 'Language is not an expression');
ok($lang->isLanguage(), 'Language is a language');

done_testing();
