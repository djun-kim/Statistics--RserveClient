use Rserve::REXP::Logical;

my $logical = new Rserve::REXP::Logical;

print "Is logical (". Rserve::Parser::xtName($logical->getType()) .") an Expression? ". $logical->isExpression() . "\n";

print "Is logical (". Rserve::Parser::xtName($logical->getType()) .") a Logical? ". $logical->isLogical() . "\n";


