use Rserve::Connection;

use Test::More tests => 10;

my $cnx = new_ok('Rserve::Connection' => ['localhost']);

@bool_scalar = $cnx->evalString('TRUE');
ok(@bool_scalar, 'return simple TRUE value') or
    diag explain @bool_scalar;

@expected_bool_vector = (1, 0);
@bool_vector = $cnx->evalString('c(TRUE, FALSE)');
is(@bool_vector, @expected_bool_vector, 'return an boolean array') or
    diag explain @bool_vector;

$expected_char_scalar = 'z';
$char_scalar = $cnx->evalString('letters[26]');
is($char_scalar, $expected_char_scalar,
   'return a scalar of single-char strings') or
    diag explain $char_scalar;

@expected_char_vector = ('a', 'b', 'c', 'd');
@char_vector = $cnx->evalString('letters[1:4]');
is(@char_vector, @expected_char_vector,
   'return a vector of single-char strings') or
    diag explain @char_vector;

$expected_string_scalar = 'Dec';
$string_scalar = $cnx->evalString('month.abb[12]');
is($string_scalar, $expected_string_scalar,
   'return a string scalar') or
    diag explain $string_scalar;

@expected_string_vector = ('Jan', 'Feb', 'Mar');
@string_vector = $cnx->evalString('month.abb[1:3]');
is(@string_vector, @expected_string_vector,
   'return a vector of strings') or
    diag explain @string_vector;

$expected_int_scalar = 123;
$int_scalar = $cnx->evalString('123L');
is($int_scalar, $expected_int_scalar,
   'return a scalar of single-int strings') or
    diag explain $int_scalar;

@expected_int_vector = (101..110);
@int_vector = $cnx->evalString('101:110');
is(@int_vector, @expected_int_vector,
   'return a vector of single-int strings') or
    diag explain @int_vector;

$expected_double_scalar = 1.5;
$double_scalar = $cnx->evalDouble('1.5');
is($double_scalar, $expected_double_scalar,
   'return a double scalar') or
    diag explain $double_scalar;

@expected_double_vector = (.5, 1, 1.5, 2);
@double_vector = $cnx->evalDouble('(1:4)/2');
is(@double_vector, @expected_double_vector,
   'return a vector of doubles') or
    diag explain @double_vector;


done_testing($number_of_tests);
