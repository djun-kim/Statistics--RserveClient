use Rserve::REXP::Raw;

my $raw = new Rserve::REXP::Raw;

print "Is raw (". Rserve::Parser::xtName($raw->getType()) .") an Expression? ". $raw->isExpression() . "\n";

print "Is raw (". Rserve::Parser::xtName($raw->getType()) .") a Raw? ". $raw->isRaw() . "\n";


