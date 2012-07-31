use Rserve::REXP;
use Rserve::REXP::Integer;

my $int = new Rserve::REXP::Integer;

print "Is int (". Rserve::Parser::xtName($int->getType()) .") an Expression? ". $int->isExpression() . "\n";

print "Is int (". Rserve::Parser::xtName($int->getType()) .") an Integer? ". $int->isInteger() . "\n";


