#!/usr/bin/env perl

$file = $ARGV[0];
$release = $ARGV[1];

if (@ARGV != 2) {
   print "Usage: $0 release_number\n";
   exit 1;
}

print "Updating $file to version $release\n";

open INPUT, "<", $file or die "Can't open file: $!\n" ;
open OUTPUT, ">", $file.'.new' or die "Can't open file: $!\n" ;

while (<INPUT>) {
   $_ =~ s/(\s*)our(\s+)\$VERSION(\s*)=(\s*)'CPAN-(\d\.\d+)';(\s*)\#VERSION/$1our$2\$VERSION$3=$4'CPAN-$release';$6#VERSION/g;

   print OUTPUT $_;
}

close INPUT;
close OUTPUT;

rename $file.'.new', $file or die "Can't rename file: $!\n";




