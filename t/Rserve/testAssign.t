use v5.12;
use warnings;
use autodie;

use Rserve::Connection;

use Test::More tests => 4;

my $cnx = new_ok('Rserve::Connection' => ['localhost']);

my @expected_true_scalar = (1);
my $x = new Rserve::REXP::Logical;
$x->setValues(\@expected_true_scalar);
$cnx->assign('x', $x);
my @true_scalar = $cnx->evalString('x');
# print join(':', @true_scalar) . "\n";
# print join(':', @expected_true_scalar) . "\n";
is_deeply(\@true_scalar, \@expected_true_scalar, 'scalar TRUE value') or
    diag explain @true_scalar;

my @expected_false_scalar = (0);
$x->setValues(\@expected_false_scalar);
$cnx->assign('x', $x);
my @false_scalar = $cnx->evalString('x');
is_deeply(\@false_scalar, \@expected_false_scalar, 'scalar FALSE value') or
    diag explain @false_scalar;

my @expected_bool_vector = (1, 0, 1);
$x->setValues(\@expected_bool_vector);
$cnx->assign('x', $x);
my @bool_vector = $cnx->evalString('x');
is_deeply(\@bool_vector, \@expected_bool_vector, 'boolean array') or
    diag explain @bool_vector;


done_testing();
