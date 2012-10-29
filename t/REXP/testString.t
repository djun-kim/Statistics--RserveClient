use v5.12;
use warnings;
use autodie;

use Rserve::REXP::String;

use Test::More tests => 12;

my $string = new Rserve::REXP::String;

isa_ok( $string, 'Rserve::REXP::String', 'new returns an object that' );
ok( !$string->isExpression(), 'String is not an expression' );
ok( $string->isString(),      'String is a string' );

ok(!defined($string->getValue()), 'default string value is undef');
is($string->__toString(), '""', 'defaultstring string');

my $expected_html = << 'END_HTML';
<div class="rexp xt_3">
<span class="typename">string</span>

</div>
END_HTML
chomp($expected_html);

is($string->toHTML(), $expected_html, 'default HTML representation');

$string->setValue('foo');
is($string->getValue(), 'foo', 'string value');
is($string->__toString(), '"foo"', 'string string');

$expected_html = << 'END_HTML';
<div class="rexp xt_3">
<span class="typename">string</span>
foo
</div>
END_HTML
chomp($expected_html);

is($string->toHTML(), $expected_html, 'HTML representation');

$string->setValue('bar');
is($string->getValue(), 'bar', 'new string value');
is($string->__toString(), '"bar"', 'new string string');

$expected_html = << 'END_HTML';
<div class="rexp xt_3">
<span class="typename">string</span>
bar
</div>
END_HTML
chomp($expected_html);

is($string->toHTML(), $expected_html, 'new HTML representation');

done_testing();
