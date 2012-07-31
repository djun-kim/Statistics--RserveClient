use Rserve::REXP::String;

my $string = new Rserve::REXP::String;

print "Is string (". Rserve::Parser::xtName($string->getType()) .") an Expression? ". $string->isExpression() . "\n";

print "Is string (". Rserve::Parser::xtName($string->getType()) .") a String? ". $string->isString() . "\n";


