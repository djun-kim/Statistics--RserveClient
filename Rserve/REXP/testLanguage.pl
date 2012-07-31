use Rserve::REXP::Language;

my $lang = new Rserve::REXP::Language;

print "Is lang (". Rserve::Parser::xtName($lang->getType()) .") an Expression? ". $lang->isExpression() . "\n";

print "Is lang (". Rserve::Parser::xtName($lang->getType()) .") a Language? ". $lang->isLanguage() . "\n";


