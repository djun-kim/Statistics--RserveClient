use Rserve::REXP::Symbol;

my $symbol = new Rserve::REXP::Symbol;

print "Is symbol (". Rserve::Parser::xtName($symbol->getType()) .") an Expression? ". $symbol->isExpression() . "\n";

print "Is symbol (". Rserve::Parser::xtName($symbol->getType()) .") a Symbol? ". $symbol->isSymbol() . "\n";


