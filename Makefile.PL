

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Statistics::RserveClient',
    VERSION_FROM => 'lib/Statistics/RserveClient/VERSION.pm', # finds \$VERSION
    AUTHOR       => 'Djun M. Kim (djun.kim@cielosystems.com)',
    ABSTRACT     => 'An Rserve Client library for the R statistics platform.',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
