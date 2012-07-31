use Rserve::REXP::GenericVector;

my $gvec = new Rserve::REXP::GenericVector;

print "Is gvec (". Rserve::Parser::xtName($gvec->getType()) .") a List? ". $gvec->isList() . "\n";

print "Is gvec (". Rserve::Parser::xtName($gvec->getType()) .") a Vector? ". $gvec->isVector() . "\n";


