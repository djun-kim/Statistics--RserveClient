use Rserve::REXP::Vector;

my @arr1 = ('a', 'b', 4);


print "==================== begin test ====================\n";
my $vector = Rserve::REXP::Vector->new();
print "$vector\n";
print "Is vector a vector?:". $vector->isVector() . "\n";

print "Length of vector is:". $vector->length() . "\n";

@v = $vector->getValues();
print "Value of vector is: @v\n";

print "setting value...\n";
$vector->setValues(\@arr1);

print "Length of vector is:". $vector->length() . "\n";
@v = $vector->getValues();

print Dumper($vector);
print "\n";

print "Value of vector is: @v\n";
print "vector as HTML is:". $vector->toHTML() . "\n";

print "--------------------\n";
my $vector2 = Rserve::REXP::Vector->new();
print "$vector2\n";
my @arr2 = ('c', 'd', $vector);
$vector2->setValues(\@arr2);
print "Length of vector2 is:". $vector2->length() . "\n";

@v2 = $vector2->getValues();
print "Value of vector2 is: @v2\n";


print "vector2 as HTML is:". $vector2->toHTML() . "\n";


