use Rserve::REXP::Unknown;

my $unknown = new Rserve::REXP::Unknown("test");

print $unknown;

print "Type is:". $unknown->getUnknownType() . "\n";


