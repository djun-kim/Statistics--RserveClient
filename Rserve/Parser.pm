# * Rserve message Parser
# * @author Djun Kim
# * Based on Clément Turbelin's PHP client
# * Licensed under GPL v2 or at your option v3

package Rserve::Parser;

use Data::Dumper;

use Rserve;
use Rserve qw( :xt_types );

use Rserve::funclib;

use Rserve::REXP;
use Rserve::REXP::Null;
use Rserve::REXP::GenericVector;

use Rserve::REXP::Symbol;
use Rserve::REXP::List;
use Rserve::REXP::Language;
use Rserve::REXP::Integer;
use Rserve::REXP::Double;
use Rserve::REXP::String;
use Rserve::REXP::Raw;
use Rserve::REXP::Logical;

use strict;
#use warnings;

use Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( parse );

use v5.12;

#my $DEBUG = Rserve::FALSE;
my $DEBUG = Rserve::TRUE;

# * Global parameters to parse() function
# * If true, use Rserve_RNative wrapper instead of native array to
#   handle attributes

#public static $use_array_object = FALSE;
my $_use_array_object = Rserve::FALSE;

sub use_array_object() {
    my $value = shift;
    if ( defined($value) ) {
        $_use_array_object = $value;
    }
    return $_use_array_object;
}

# * Transform factor to native strings, only for parse() method
# * If false, factors are parsed as integers
#public static $factor_as_string = TRUE;
my $_factor_as_string = Rserve::TRUE;

sub factor_as_string() {
    my $value = shift;
    if ( defined($value) ) {
        $_factor_as_string = $value;
    }
    return $_factor_as_string;
}

# * parse SEXP results -- limited implementation for now (large
#   packets and some data types are not supported)
# * @param string $buf
# * @param int $offset
# * @param unknown_type $attr
#public static function parse($buf, $offset, $attr = NULL) {
sub parse($\$;\@) {
    # print Dumper(@_);

    print( "debug: In parse(); caller is " . caller() . "\n" );
    my $buf = shift;
    #    my $offset = ${shift()};
    my $offset = shift;
    my @attr   = ();

    print "parse:buf = $buf\n";
    print "parse:offset = $offset\n";

    if ( @_ == 1 ) {
        print "num args = 3\n";
        @attr = shift;
    }
    elsif ( @_ == 2 ) {
        print "num args = 2\n";
    }
    else {
        print "num args is " . @_ . "\n";
        die "Rserve::Parser::parse(): too few arguments.\n";
    }

    print "parse:buf = $buf\n";
    print "parse:offset = $offset\n";
    print "parse:attr = @attr\n";

    use vars qw(@a);
    @a = ();

    my @names = ();
    my @na    = ();
    my @r     = split '', $buf;

    foreach (@r) { print "[" . ord($_) . ":" . $_ . "]" }
    print "\n";

    my $i = $$offset;
    my $eoa;

    # some simple parsing - just skip attributes and assume short responses
    my $ra = int8( \@r, $i );
    my $rl = int24( \@r, $i + 1 );

    print "ra = $ra\n";
    print "rl = $rl\n";

    my $al;

    $i += 4;

    $$offset = $eoa = $i + $rl;
    print '[ '
        . Rserve::Parser::xtName( $ra & 63 )
        . ', length '
        . $rl . ' ['
        . $i . ' - '
        . $eoa . "]\n";
    if ( ( $ra & 64 ) == 64 ) {
        throw new Exception('long packets are not supported (yet).');
    }
    if ( $ra > Rserve::XT_HAS_ATTR ) {
        # print '(ATTR*[';
        $ra &= ~Rserve::XT_HAS_ATTR;
        $al = int24( \@r, $i + 1 );
        @attr = parse( $buf, $i, @attr );
        # print '])';
        $i += $al + 4;
    }

    given ($ra) {
        when (Rserve::XT_NULL) {
            print "Null\n" if $DEBUG;
            @a = undef;
        }
        when (Rserve::XT_VECTOR) {    # generic vector
            print "Vector" if $DEBUG;
            @a = undef;
            while ( $i < $eoa ) {
                print "******* i = $i\n" if $DEBUG;
                #$a[] = parse($buf, &$i);
                print("recursive call to parse($buf, $i)\n");
                my @parse_result = parse( $buf, \$i, @attr );
                push( @a, \@parse_result );
                print "*{" . Dumper(@parse_result) . "}*\n";
                print Dumper(@a) . "\n";
            }
            print Dumper(@a);
         # if the 'names' attribute is set, convert the plain array into a map
            if ( defined( $attr['names'] ) ) {
                @names = $attr['names'];
                @na    = ();
                my $n = length($a);
                for ( my $k = 0; $k < $n; $k++ ) {
                    $na[ $names[$k] ] = $a[$k];
                }
                @a = @na;
            }
        }

        when (Rserve::XT_INT) {
            print "Rserve::XT_INT\n" if $DEBUG;
            @a = int32( \@r, $i );
            $i += 4;
        }

        when (Rserve::XT_DOUBLE) {
            print "Rserve::XT_DOUBLE\n" if $DEBUG;
            @a = flt64( \@r, $i );

            foreach (@r) { print "[" . ord($_) . ":" . $_ . "]" }
            print "\n";

            print Dumper(@r);

            foreach (@a) { print "[" . ord($_) . ":" . $_ . "]" }
            print "\n";

            $i += 8;
        }

        when (Rserve::XT_BOOL) {
            print "Rserve::XT_BOOL\n" if $DEBUG;
            my $v = int8( \@r, $i++ );
            @a
                = ( $v == 1 )
                ? Rserve::TRUE
                : ( ( $v == 0 ) ? Rserve::FALSE : undef );
        }

        when (Rserve::XT_SYMNAME) {    # symbol
            print "Rserve::XT_SYMNAME\n" if $DEBUG;
            my $oi = $i;
            while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
                $i++;
            }
            @a = split '', substr( $buf, $oi, $i - $oi );
        }

        when ( Rserve::XT_LANG_NOTAG or Rserve::XT_LIST_NOTAG )
        {                              # pairlist w/o tags
            print "Rserve::XT_LANG_NOTAG or Rserve::XT_LIST_NOTAG\n"
                if $DEBUG;
            @a = ();
            while ( $i < $eoa ) {
                # $a[] = self::parse($buf, &$i);
                push( @a, parse( $buf, $i, @attr ) );
            }
        }

        when ( Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG )
        {                              # pairlist with tags
            print "Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG\n" if $DEBUG;
            @a = ();
            while ( $i < $eoa ) {
                my $val = parse( $buf, $i, @attr );
                my $tag = parse( $buf, $i, @attr );
                @a[$tag] = $val;
            }
        }

        when (Rserve::XT_ARRAY_INT) {    # integer array
            print "Rserve::XT_ARRAY_INT\n" if $DEBUG;
            @a = ();
            while ( $i < $eoa ) {
                # $a[] = int32(@r, $i);
                push( @a, int32( \@r, $i ) );
                $i += 4;
            }
            if ( scalar(@a) == 1 ) {
                @a = @a[0];
            }
            # If factor, then transform to characters
            #if (self::$factor_as_string and isset($attr['class'])) {
            if ( factor_as_string() and defined( $attr['class'] ) ) {
                my $c = $attr['class'];
                if ( $c eq 'factor' ) {
                    my $n      = scalar(@a);
                    my @levels = $attr['levels'];
                    for ( my $k = 0; $k < $n; ++$k ) {
                        $i = @a[$k];
                        if ( $i < 0 ) {
                            $a[$k] = undef;
                        }
                        else {
                            $a[$k] = $levels[ $i - 1 ];
                        }
                    }
                }
            }
        }

        when (Rserve::XT_ARRAY_DOUBLE) {    # double array
            print "Rserve::XT_ARRAY_DOUBLE\n" if $DEBUG;
            @a = ();
            while ( $i < $eoa ) {
                #$a[] = flt64(@r, $i);
                push( @a, flt64( \@r, $i ) );
                $i += 8;
            }
            if ( scalar(@a) == 1 ) {
                @a = $a[0];
            }
        }

        when (Rserve::XT_ARRAY_STR) {    # string array
            print "Rserve::XT_ARRAY_STR\n" if $DEBUG;
            @a = ();
            my $oi = $i;

            #print "i = $i\n";
            #print "eoa = $eoa\n";

            while ( $i < $eoa ) {
                if ( ord( $r[$i] ) == 0 ) {
                    #$a[] = substr($r, $oi, $i - $oi);
                    push( @a, join( '', @r[ $oi .. $i - 1 ] ) );
                    $oi = $i + 1;
                }
                $i++;
            }
            if ( scalar(@a) == 1 ) {
                @a = $a[0];
            }
        }

        when (Rserve::XT_ARRAY_BOOL) {    # boolean vector
            print "Rserve::XT_ARRAY_BOOL\n" if $DEBUG;
            my $n = int32( \@r, $i );
            $i += 4;
            my $k = 0;
            @a = ();
            while ( $k < $n ) {
                my $v = int8( \@r, $i++ );
                $a[ $k++ ]
                    = ( $v == 1 )
                    ? Rserve::TRUE
                    : ( ( $v == 0 ) ? Rserve::FALSE : undef );
            }
            if ( $n == 1 ) {
                @a = $a[0];
            }
        }

        when (Rserve::XT_RAW) {    # raw vector
            print "Rserve::XT_RAW\n" if $DEBUG;
            my $len = int32( \@r, $i );
            $i += 4;
            @a = splice( @r, $i, $len );
        }

        # when(Rserve::XT_ARRAY_CPLX) {
        # }

        when (48) {    # unimplemented type in Rserve
            my $uit = int32( \@r, $i );
        # echo "Note: result contains type #$uit unsupported by Rserve.<br/>";
            @a = undef;
        }

        default {
            print(    'Warning: type '
                    . $ra
                    . ' is currently not implemented in the Perl client.' );
            @a = undef;
        }
    }    # end switch

    #if (self::$use_array_object) {
    if ( use_array_object() ) {
        # if ( is_array(@a) & @attr ) {
        if ( ( ref(@a) == 'ARRAY' ) & @attr ) {
            return new Rserve::RNative( @a, @attr );
        }
        else {
            return @a;
        }
    }
    return @a;
}

# * parse SEXP to Debug array(type, length,offset, contents, n)
# * @param string $buf
# * @param int $offset
# * @param unknown_type $attr
sub parseDebug($;\$\@) {
    print "parseDebug()\n";

    my $buf;
    my $offset;
    my @attr = ();

    if ( @_ == 3 ) {
        $buf    = shift;
        $offset = shift;
        @attr   = shift;
    }
    elsif ( @_ == 2 ) {
        ( $buf, $offset ) = shift;
    }
    elsif ( @_ == 1 ) {
        die "Rserve::Parser::parse(): too few arguments.\n";
    }

    print "buf = $buf\n"       if $DEBUG;
    print "offset = $offset\n" if $DEBUG;

    my @r = split '', $buf;

    my $i = $offset;

    my @a = ();

    # some simple parsing - just skip attributes and assume short responses
    my $ra = int8( \@r, $i );
    my $rl = int24( \@r, $i + 1 );

    print "ra = $ra\n" if $DEBUG;
    print "rl = $ra\n" if $DEBUG;

    $i += 4;

    my $eoa;
    my $offset = $eoa = $i + $rl;

    my @result = ();

    $result['type']   = Rserve::Parser::xtName( $ra & 63 );
    $result['length'] = $rl;
    $result['offset'] = $i;
    $result['eoa']    = $eoa;
    if ( ( $ra & 64 ) == 64 ) {
        $result['long'] = Rserve::TRUE;
        return @result;
    }
    if ( $ra > Rserve::XT_HAS_ATTR ) {

        $ra &= ~Rserve::XT_HAS_ATTR;
        my $al = int24( \@r, $i + 1 );
        @attr = parseDebug( $buf, $i );
        $result['attr'] = @attr;
        $i += $al + 4;
    }
    if ( $ra == Rserve::XT_NULL ) {
        return @result;
    }
    if ( $ra == Rserve::XT_VECTOR ) {    # generic vector
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = self::parseDebug($buf, &$i);
            push( @a, parseDebug( $buf, $i ) );
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_SYMNAME ) {    # symbol
        my $oi = $i;
        while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
            $i++;
        }
        $result['contents'] = substr( $buf, $oi, $i - $oi );
    }
    if ( $ra == Rserve::XT_LIST_NOTAG || $ra == Rserve::XT_LANG_NOTAG )
    {                                     # pairlist w/o tags
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = self::parseDebug($buf, &$i);
            push( @a, parseDebug( $buf, $i ) );
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_LIST_TAG || $ra == Rserve::XT_LANG_TAG )
    {                                     # pairlist with tags
        @a = ();
        while ( $i < $eoa ) {
            my $val = parseDebug( $buf, $i );
            my $tag = parse( $buf, $i, @attr );
            $a[$tag] = $val;
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_INT ) {    # integer array
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = int32(@r, $i);
            push( @a, int32( \@r, $i ) );
            $i += 4;
        }
        if ( length($a) == 1 ) {
            $result['contents'] = $a[0];
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_DOUBLE ) {    # double array
        @a = ();
        while ( $i < $eoa ) {
            push( @a, flt64( \@r, $i ) );
            $i += 8;
        }
        if ( length($a) == 1 ) {
            $result['contents'] = $a[0];
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_STR ) {       # string array
        @a = ();
        my $oi = $i;
        while ( $i < $eoa ) {
            if ( ord( $r[$i] ) == 0 ) {
                # $a[] = substr($r, $oi, $i - $oi);
                push( @a, splice( @r, $oi, $i - $oi ) );
                $oi = $i + 1;
            }
            $i++;
        }
        if ( length($a) == 1 ) {
            $result['contents'] = $a[0];
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_BOOL ) {    # boolean vector
        my $n = int32( \@r, $i );
        $result['size'] = $n;
        $i += 4;
        my $k = 0;
        @a = ();
        while ( $k < $n ) {
            my $v = int8( \@r, $i++ );
  # $a[$k] = ($v === 1) ? Rserve::TRUE : (($v === 0) ? Rserve::FALSE : undef);
            $a[$k]
                = ( ( $v == 1 ) && is_number($v) )
                ? Rserve::TRUE
                : (
                ( ( $v == 0 ) && is_number($v) ) ? Rserve::FALSE : undef );
            ++$k;
        }
        if ( length($a) == 1 ) {
            $result['contents'] = $a[0];
        }
        $result['contents'] = $a;
    }
    if ( $ra == Rserve::XT_RAW ) {    # raw vector
        my $len = int32( \@r, $i );
        $i += 4;
        $result['size'] = $len;
        my $contents = join( '', substr( @r, $i, $len ) );
        $result['contents'] = $contents;
    }
    if ( $ra == Rserve::XT_ARRAY_CPLX ) {
        $result['not_implemented'] = Rserve::TRUE;
        # TODO: complex
    }
    if ( $ra == 48 ) {                # unimplemented type in Rserve
        my $uit = int32( \@r, $i );
        $result['unknownType'] = $uit;
    }
    return @result;
}

#public static function parseREXP($buf, $offset, $attr = NULL) {
sub parseREXP($;\$\@) {

    print "parseREXP()\n" if $DEBUG;

    my $buf;
    my $offset;
    my @attr = ();

    if ( @_ == 3 ) {
        $buf    = shift;
        $offset = shift;
        @attr   = shift;
    }
    elsif ( @_ == 2 ) {
        ( $buf, $offset ) = shift;
    }
    elsif ( @_ == 1 ) {
        die "Rserve::Parser::parse(): too few arguments.\n";
    }

    #print "buf = $buf\n";
    #print "offset = $offset\n";

    my @r = split '', $buf;
    my $i = $offset;

    my @v = ();

    # some simple parsing - just skip attributes and assume short responses
    my $ra = int8( \@r, $i );
    my $rl = int24( \@r, $i + 1 );

    print "ra = $ra\n" if $DEBUG;
    print "rl = $ra\n" if $DEBUG;

    # print Dumper($rl);

    #my $eoa = int24(0);
    my $eoa = 0;

    my $al, $i += 4;

    $offset = $eoa = $i + $rl;
    if ( ( $ra & 64 ) == 64 ) {
        throw new Exception('Long packets are not supported (yet).');
    }

    if ( $ra > Rserve::XT_HAS_ATTR ) {
        $ra &= ~Rserve::XT_HAS_ATTR;
        $al = int24( \@r, $i + 1 );
        @attr = parseREXP( $buf, $i, @attr );
        $i += $al + 4;
    }
    given ($ra) {
        when (Rserve::XT_NULL) {
            print "Rserve::XT_NULL\n" if $DEBUG;
            $a = new Rserve::REXP::Null();
        }
        when (Rserve::XT_VECTOR) {    # generic vector
            print "Rserve::XT_VECTOR\n" if $DEBUG;
            @v = ();
            while ( $i < $eoa ) {
                # $v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, $i, @attr ) );
            }
            $a = new Rserve::REXP::GenericVector();
            $a->setValues(@v);
        }

        when (Rserve::XT_SYMNAME) {    # symbol
            print "Rserve::XT_SYMNAME\n" if $DEBUG;
            my $oi = $i;
            while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
                $i++;
            }
            my $v = substr( $buf, $oi, $i - $oi );
            my $a = new Rserve::REXP::Symbol();
            my $a->setValue($v);
        }
        when ( Rserve::XT_LIST_NOTAG or Rserve::XT_LANG_NOTAG )
        {                              # pairlist w/o tags
            print "Rserve::XT_LIST_NOTAG or Rserve::XT_LANG_NOTAG\n"
                if $DEBUG;
            @v = ();
            while ( $i < $eoa ) {
                #$v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, $i, @attr ) );
            }
            my $clasz
                = ( $ra == Rserve::XT_LIST_NOTAG )
                ? 'Rserve::REXP::List'
                : 'Rserve::REXP::Language';
            $a = new ${clasz}();
            $a->setValues($a);
        }

        when ( Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG )
        {    # pairlist with tags
            print "Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG\n" if $DEBUG;
            my $clasz
                = ( $ra == Rserve::XT_LIST_TAG )
                ? 'Rserve::REXP::List'
                : 'Rserve::REXP::Language';
            my @v     = ();
            my @names = ();
            while ( $i < $eoa ) {
                #$v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, $i, @attr ) );
                # $names[] = self::parseREXP($buf, &$i);
                push( @names, parseREXP( $buf, $i, @attr ) );
            }
            $a = new ${clasz}();
            $a->setValues(@v);
            $a->setNames(@names);
        }

        when (Rserve::XT_ARRAY_INT) {    # integer array
            print "Rserve::XT_ARRAY_INT\n" if $DEBUG;
            my @v = ();
            while ( my $i < $eoa ) {
                #$v[] = int32(@r, $i);
                push( @v, int32( \@r, $i ) );
                $i += 4;
            }
            $a = new Rserve::REXP::Integer();
            $a->setValues(@v);
        }

        when (Rserve::XT_ARRAY_DOUBLE) {    # double array
            print "Rserve::XT_ARRAY_DOUBLE\n" if $DEBUG;
            @v = ();
            while ( my $i < $eoa ) {
                # $v[] = flt64($r, $i);
                push( @v, flt64( \@r, $i ) );
                $i += 8;
            }
            $a = new Rserve::REXP::Double();
            $a->setValues(@v);
        }

        when (Rserve::XT_ARRAY_STR) {       # string array
            prin t "Rserve::XT_ARRAY_STR\n";
            @v = ();
            my $oi = $i;
            while ( my $i < $eoa ) {
                if ( ord( $r[$i] ) == 0 ) {
                    # $v[] = substr($r, $oi, $i - $oi);
                    push( @v, substr( @r, $oi, $i - $oi ) );
                    $oi = $i + 1;
                }
                $i++;
            }
            $a = new Rserve::REXP::String();
            $a->setValues(@v);
        }

        when (Rserve::XT_ARRAY_BOOL) {    # boolean vector
            print "Rserve::XT_ARRAY_BOOL\n" if $DEBUG;
            my $n = int32( \@r, $i );
            $i += 4;
            my $k  = 0;
            my @vv = ();
            while ( $k < $n ) {
                my $v = int8( \@r, $i++ );
                $vv[$k]
                    = ( $v == 1 )
                    ? Rserve::TRUE
                    : ( ( $v == 0 ) ? Rserve::FALSE : undef );
                $k++;
            }
            $a = new Rserve::REXP::Logical();
            $a->setValues(@vv);
        }

        when (Rserve::XT_RAW) {    # raw vector
            print "Rserve::XT_RAW\n" if $DEBUG;
            my $len = int32( \@r, $i );
            $i += 4;
            my @v = substr( @r, $i, $len );
            my $a = new Rserve::REXP::Raw();
            $a->setValue(@v);
        }

        when (Rserve::XT_ARRAY_CPLX) {
            print "Rserve::XT_ARRAY_CPLX\n" if $DEBUG;
            $a = Rserve::FALSE;
        }

        when (48) {    # unimplemented type in Rserve
            print "48\n" if $DEBUG;
            my $uit = int32( \@r, $i );
        # echo "Note: result contains type #$uit unsupported by Rserve.<br/>";
            @a = undef;
        }

        default {
            print(    'Warning: type '
                    . $ra
                    . ' is currently not implemented in the Perl client.' );
            @a = Rserve::FALSE;
        }
    }

    if ($DEBUG) {
        print "dumping a:\n";
        print Dumper(@a);
        print "done\n";
    }

    if ( scalar(@attr) && is_object(@a) ) {
        @a->setAttributes(@attr);
    }

    return @a;
}

#public static function  xtName($xt) {

sub xtName($) {

    my $xt = shift;

    given ($xt) {
        when (Rserve::XT_NULL)         { return ('null'); }
        when (Rserve::XT_INT)          { return 'int'; }
        when (Rserve::XT_STR)          { return 'string'; }
        when (Rserve::XT_DOUBLE)       { return 'real'; }
        when (Rserve::XT_BOOL)         { return 'logical'; }
        when (Rserve::XT_ARRAY_INT)    { return 'int*'; }
        when (Rserve::XT_ARRAY_STR)    { return 'string*'; }
        when (Rserve::XT_ARRAY_DOUBLE) { return 'real*'; }
        when (Rserve::XT_ARRAY_BOOL)   { return 'logical*'; }
        when (Rserve::XT_ARRAY_CPLX)   { return 'complex*'; }
        when (Rserve::XT_SYM)          { return 'symbol'; }
        when (Rserve::XT_SYMNAME)      { return 'symname'; }
        when (Rserve::XT_LANG)         { return 'lang'; }
        when (Rserve::XT_LIST)         { return 'list'; }
        when (Rserve::XT_LIST_TAG)     { return 'list+T'; }
        when (Rserve::XT_LIST_NOTAG)   { return 'list/T'; }
        when (Rserve::XT_LANG_TAG)     { return 'lang+T'; }
        when (Rserve::XT_LANG_NOTAG)   { return 'lang/T'; }
        when (Rserve::XT_CLOS)         { return 'clos'; }
        when (Rserve::XT_RAW)          { return 'raw'; }
        when (Rserve::XT_S4)           { return 'S4'; }
        when (Rserve::XT_VECTOR)       { return 'vector'; }
        when (Rserve::XT_VECTOR_STR)   { return 'string[]'; }
        when (Rserve::XT_VECTOR_EXP)   { return 'expr[]'; }
        when (Rserve::XT_FACTOR)       { return 'factor'; }
        when (Rserve::XT_UNKNOWN)      { return 'unknown'; }
    }
    return '<? ' . $xt . '>';
}

# * @param Rserve::REXP $value
#  * This function is not functional. Please use it only for testing
#public static function createBinary(Rserve::REXP $value) {
sub createBinary($) {

    my $value = shift;
    # Current offset
    my $o        = 0;                   # Init with header size
    my $contents = '';
    my $type     = $value->getType();
    given ($type) {
        when (Rserve::XT_S4) { continue; }
        when (Rserve::XT_NULL) {
        }
        when (Rserve::XT_INT) {
            my $v = 0 + $value->at(0);
            $contents .= mkint32($v);
            $o += 4;
        }
        when (Rserve::XT_DOUBLE) {
            my $v = 0.0 + $value->at(0);
            $contents .= mkfloat64($v);
            $o += 8;
        }
        when (Rserve::XT_ARRAY_INT) {
            my @vv = $value->getValues();
            my $n  = scalar(@vv);
            my $v;
            for ( my $i = 0; $i < $n; ++$i ) {
                $v = $vv[$i];
                $contents .= mkint32($v);
                $o += 4;
            }
        }
        when (Rserve::XT_ARRAY_BOOL) {
            my @vv = $value->getValues();
            my $n  = scalar(@vv);
            my $v;
            $contents .= mkint32($n);
            $o += 4;
            if ($n) {
                for ( my $i = 0; $i < $n; ++$i ) {
                    $v = $vv[$i];
                    if ( defined($v) ) {
                        $v = 2;
                    }
                    else {
                        $v = 0 + $v;
                    }
                    if ( $v != 0 and $v != 1 ) {
                        $v = 2;
                    }
                    $contents .= chr($v);
                    ++$o;
                }
                while ( ( $o & 3 ) != 0 ) {
                    $contents .= chr(3);
                    ++$o;
                }
            }
        }
        when (Rserve::XT_ARRAY_DOUBLE) {
            my @vv = $value->getValues();
            my $n  = scalar(@vv);
            my $v;
            for ( my $i = 0; $i < $n; ++$i ) {
                $v = 0.0 + $vv[$i];
                $contents .= mkfloat64($v);
                $o += 8;
            }
        }
        when (Rserve::XT_RAW) {
            my $v = $value->getValue();
            my $n = $value->length();
            $contents .= mkint32($n);
            $o += 4;
            $contents .= $v;
        }
        when (Rserve::XT_ARRAY_STR) {
            my @vv = $value->getValues();
            my $n  = scalar(@vv);
            my @v;
            for ( my $i = 0; $i < $n; ++$i ) {
                @v = $vv[$i];
                if (@v) {
                    if ( ord( $v[0] ) == 255 ) {
                        $contents .= chr(255);
                        ++$o;
                    }
                    $contents .= join( '', @v );
                    $o += scalar(@v);
                }
                else {
                    $contents .= chr(255) . chr(0);
                    $o += 2;
                }
            }
            while ( ( $o & 3 ) != 0 ) {
                $contents .= chr(1);
                ++$o;
            }
        }
        when (Rserve::XT_LIST_TAG)   { continue; }
        when (Rserve::XT_LIST_NOTAG) { continue; }
        when (Rserve::XT_LANG_TAG)   { continue; }
        when (Rserve::XT_LANG_NOTAG) { continue; }
        when (Rserve::XT_LIST)       { continue; }
        when (Rserve::XT_VECTOR)     { continue; }
        when (Rserve::XT_VECTOR_EXP) {
            my @l     = $value->getValues();
            my @names = ();
            if (   $type == Rserve::XT_LIST_TAG
                || $type == Rserve::XT_LANG_TAG )
            {
                @names = $value->getNames();
            }
            my $i = 0;
            my $n = scalar(@l);
            while ( $i < $n ) {
                my $x = $l[$i];
                if ( defined($x) ) {
                    $x = new Rserve::REXP::Null();
                }
                my $iof = strlen($contents);
                $contents .= createBinary($x);
                if (   $type == Rserve::XT_LIST_TAG
                    || $type == Rserve::XT_LANG_TAG )
                {
                    my $sym = new Rserve::REXP::Symbol();
                    $sym->setValue( $names[$i] );
                    $contents .= createBinary($sym);
                }
                ++$i;
            }
        }

        when ( Rserve::XT_SYMNAME or Rserve::XT_STR ) {
            my $s = '' . $value->getValue();
            $contents .= $s;
            $o += strlen($s);
            $contents .= chr(0);
            ++$o;
            #padding if necessary
            while ( ( $o & 3 ) != 0 ) {
                $contents .= chr(0);
                ++$o;
            }
        }
    }

    #
    # TODO: handling attr
    #  $attr = $value->attr();
    #  $attr_bin = '';
    #  if (defined($attr) ) {
    #    $attr_off = self::createBinary($attr, $attr_bin, 0);
    #    $attr_flag = Rserve::XT_HAS_ATTR;
    #   }
    #   else {
    #     $attr_off = 0;
    #     $attr_flag = 0;
    #   }
    # [0]   (4) header SEXP: len=4+m+n, XT_HAS_ATTR is set
    # [4]   (4) header attribute SEXP: len=n
    # [8]   (n) data attribute SEXP
    # [8+n] (m) data SEXP

    my $attr_flag = 0;
    my $length    = $o;
    my $isLarge   = ( $length > 0xfffff0 );
    my $code      = $type | $attr_flag;

    # SEXP Header (without ATTR)
    # [0]  (byte) eXpression Type
    # [1]  (24-bit int) length
    my @r;
    push( @r, chr( $code & 255 ) );
    push( @r, mkint24($length) );
    push( @r, $contents );
    return @r;
}

sub is_object($$) {
    # blessed $_[1] && $_[1]->isa($_[0]);
    my ( $obj, $name );
    if ( defined($obj) ) {
        return isa $obj, $name;
    }
    else {
        return Rserve::FALSE;
    }
}

1;
