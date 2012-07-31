use Rserve::REXP::Null;

my $null = new Rserve::REXP::Null;

print "Is null (". Rserve::Parser::xtName($null->getType()) .") an Expression? ". $null->isExpression() . "\n";

print "Is null (". Rserve::Parser::xtName($null->getType()) .") a Null? ". $null->isNull() . "\n";


