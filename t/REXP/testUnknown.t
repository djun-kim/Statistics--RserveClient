use v5.12;
use warnings;
use autodie;

use Rserve::REXP::Unknown;

use Test::More tests => 2;

my $unknown = new Rserve::REXP::Unknown('test');

isa_ok($unknown, 'Rserve::REXP::Unknown', 'new returns an object that');
is($unknown->getUnknownType(), 'test', 'Unknown is an unknown "test"');

done_testing();

