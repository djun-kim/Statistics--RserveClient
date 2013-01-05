# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Statistics::RserveClient' ); }

my $object = Statistics::RserveClient->new ();
isa_ok ($object, 'Statistics::RserveClient');


