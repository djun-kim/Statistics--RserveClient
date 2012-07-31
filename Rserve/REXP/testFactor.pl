use Rserve::REXP::Factor;

my $fact = new Rserve::REXP::Factor;

print "Is fact (". Rserve::Parser::xtName($fact->getType()) .") an Expression? ". $fact->isExpression() . "\n";

print "Is fact (". Rserve::Parser::xtName($fact->getType()) .") a Factor? ". $fact->isFactor() . "\n";

print "Is fact (". Rserve::Parser::xtName($fact->getType()) .") an Integer? ". $fact->isInteger() . "\n";


