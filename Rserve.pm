# * Rserve
# * @author Djun Kim
# * Licensed under GPL v2 or at your option v3

use v5.12;
use warnings;
use autodie;

package Rserve;

use Exporter;

use constant FALSE => 0;
use constant TRUE  => 1;
our @EXPORT = qw( TRUE FALSE );

our @EXPORT_OK = (
    'XT_NULL',       'XT_INT',
    'XT_DOUBLE',     'XT_STR',
    'XT_LANG',       'XT_SYM',
    'XT_BOOL',       'XT_S4',
    'XT_VECTOR',     'XT_LIST',
    'XT_CLOS',       'XT_SYMNAME',
    'XT_LIST_NOTAG', 'XT_LIST_TAG',
    'XT_LANG_NOTAG', 'XT_LANG_TAG',
    'XT_VECTOR_EXP', 'XT_VECTOR_STR',
    'XT_ARRAY_INT',  'XT_ARRAY_DOUBLE',
    'XT_ARRAY_STR',  'XT_ARRAY_BOOL_UA',
    'XT_ARRAY_BOOL', 'XT_RAW',
    'XT_ARRAY_CPLX', 'XT_UNKNOWN',
    'XT_FACTOR',     'XT_HAS_ATTR',
);

our %EXPORT_TAGS = (
    xt_types => [
        'XT_NULL',       'XT_INT',
        'XT_DOUBLE',     'XT_STR',
        'XT_LANG',       'XT_SYM',
        'XT_BOOL',       'XT_S4',
        'XT_VECTOR',     'XT_LIST',
        'XT_CLOS',       'XT_SYMNAME',
        'XT_LIST_NOTAG', 'XT_LIST_TAG',
        'XT_LANG_NOTAG', 'XT_LANG_TAG',
        'XT_VECTOR_EXP', 'XT_VECTOR_STR',
        'XT_ARRAY_INT',  'XT_ARRAY_DOUBLE',
        'XT_ARRAY_STR',  'XT_ARRAY_BOOL_UA',
        'XT_ARRAY_BOOL', 'XT_RAW',
        'XT_ARRAY_CPLX', 'XT_UNKNOWN',
        'XT_FACTOR',     'XT_HAS_ATTR',
    ]
);

my %typeHash = ();

# xpression type: NULL
use constant XT_NULL => 0;
$typeHash{0} = 'XT_NULL';

# xpression type: integer
use constant XT_INT => 1;
$typeHash{1} = 'XT_INT';

# xpression type: double
use constant XT_DOUBLE => 2;
$typeHash{2} = 'XT_DOUBLE';

# xpression type: String
use constant XT_STR => 3;
$typeHash{3} = 'XT_STR';

# xpression type: language construct (currently content is same as list)
use constant XT_LANG => 4;
$typeHash{4} = 'XT_LANG';

# xpression type: symbol (content is symbol name: String)
use constant XT_SYM => 5;
$typeHash{5} = 'XT_SYM';

# xpression type: RBool
use constant XT_BOOL => 6;
$typeHash{6} = 'XT_BOOL';

# xpression type: S4 object
#  @since Rserve 0.5
use constant XT_S4 => 7;
$typeHash{7} = 'XT_S4';

# xpression type: generic vector (RList)
use constant XT_VECTOR => 16;
$typeHash{16} = 'XT_VECTOR';

# xpression type: dotted-pair list (RList)
use constant XT_LIST => 17;
$typeHash{17} = 'XT_LIST';

# xpression type: closure
# (there is no java class for that type (yet?).
# Currently the body of the closure is stored in the content
# part of the REXP. Please note that this may change in the future!)
use constant XT_CLOS => 18;
$typeHash{18} = 'XT_CLOS';

# xpression type: symbol name
# @since Rserve 0.5
use constant XT_SYMNAME => 19;
$typeHash{19} = 'XT_SYMNAME';

# xpression type: dotted-pair list (w/o tags)
# @since Rserve 0.5
use constant XT_LIST_NOTAG => 20;
$typeHash{20} = 'LIST_NOTAG';

# xpression type: dotted-pair list (w tags)
# @since Rserve 0.5
use constant XT_LIST_TAG => 21;
$typeHash{21} = 'LIST_TAG';

# xpression type: language list (w/o tags)
# @since Rserve 0.5
use constant XT_LANG_NOTAG => 22;
$typeHash{22} = 'LANG_NOTAG';

# xpression type: language list (w tags)
# @since Rserve 0.5
use constant XT_LANG_TAG => 23;
$typeHash{23} = 'LANG_TAG';

# xpression type: expression vector
use constant XT_VECTOR_EXP => 26;
$typeHash{26} = 'VECTOR_EXP';

# xpression type: string vector
use constant XT_VECTOR_STR => 27;
$typeHash{27} = 'VECTOR_STR';

# xpression type: int[]
use constant XT_ARRAY_INT => 32;
$typeHash{32} = 'ARRAY_INT';

# xpression type: double[]
use constant XT_ARRAY_DOUBLE => 33;
$typeHash{33} = 'ARRAY_DOUBLE';

# xpression type: String[] (currently not used, Vector is used instead)
use constant XT_ARRAY_STR => 34;
$typeHash{34} = 'ARRAY_STR';

# internal use only! this constant should never appear in a REXP
use constant XT_ARRAY_BOOL_UA => 35;
$typeHash{35} = 'XT_ARRAY_BOOL_UA';

# xpression type: RBool[]
use constant XT_ARRAY_BOOL => 36;
$typeHash{36} = 'XT_ARRAY_BOOL';

# xpression type: raw (byte[])
# @since Rserve 0.4-?
use constant XT_RAW => 37;
$typeHash{37} = 'XT_RAW';

# xpression type: Complex[]
# @since Rserve 0.5
use constant XT_ARRAY_CPLX => 38;
$typeHash{38} = 'ARRAY_CPLX';

# xpression type: unknown; no assumptions can be made about the content
use constant XT_UNKNOWN => 48;
$typeHash{48} = 'XT_UNKNOWN';

# xpression type: RFactor; this XT is internally generated (ergo is
# does not come from Rsrv.h) to support RFactor class which is built
# from XT_ARRAY_INT
use constant XT_FACTOR => 127;
$typeHash{127} = 'XT_FACTOR';

# used for transport only - has attribute
use constant XT_HAS_ATTR => 128;
$typeHash{128} = 'HAS_ATTR';

1;
