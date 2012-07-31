use Rserve::REXP::Expression;
use Rserve::REXP::Double;

my $expr = new Rserve::REXP::Expression;

print "Is expr (". Rserve::Parser::xtName($expr->getType()) .")an Expression? ". $expr->isExpression() . "\n";

my $dbl = new Rserve::REXP::Double;

print "Is dbl (". Rserve::Parser::xtName($dbl->getType()) .") an Expression? ". $dbl->isExpression() . "\n";


