use Rserve::REXP::Double;

my $dbl = new Rserve::REXP::Double;

my @val = (1.0, 2.0, 3.0);
$dbl->setValues(\@val);

print "Is dbl a Double? (expect TRUE) ". $dbl->isDouble() . "\n";
print "Is dbl a Vector? (expect TRUE) ". $dbl->isVector() . "\n";
print "dbl as HTML:\n";
print $dbl->toHTML();



