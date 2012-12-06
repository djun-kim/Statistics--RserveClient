# * Rserve message Parser
# * @author Djun Kim
# * Based on Clément Turbelin's PHP client
# * Licensed under GPL v2 or at your option v3

package Rserve::Parser;

#use strict;
#use warnings;
#use diagnostics;

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(parse);

use Data::Dumper;

#use Rserve;

#use Rserve::ParserException;

use Rserve::funclib;
use Rserve qw( :xt_types );

use Rserve::REXP;

#use Rserve::REXP::Null;
#use Rserve::REXP::GenericVector;

#use Rserve::REXP::Symbol;
#use Rserve::REXP::List;
#use Rserve::REXP::Language;
#use Rserve::REXP::Integer;
#use Rserve::REXP::Double;
#use Rserve::REXP::String;
#use Rserve::REXP::Raw;
#use Rserve::REXP::Logical;


# * Global parameters to parse() function
# * If true, use Rserve_RNative wrapper instead of native array to
#   handle attributes

#public static $use_array_object = FALSE;
my $_use_array_object = Rserve::FALSE;

#forward definition to avoid warnings pragma complaints
sub use_array_object();

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

sub parse($\$;%);

sub parse($\$;%) {
    Rserve::debug "parse()\n";

    my $buf;
    my $offset;
    my %attr = ();

    $offset = 0;

    Rserve::debug Dumper(@_);

    my $n = @_;
    Rserve::debug "num args = $n\n";

    if ( @_ == 3 ) {
        $buf    = shift;
        my $offset_ref = shift;
        $offset = $$offset_ref;
        %attr   = shift;
    }
    elsif ( @_ == 2 ) {
        $buf = shift;
        my $offset_ref = shift;
        $offset = $$offset_ref;
    }
    elsif ( @_ == 1 ) {
        die "Rserve::Parser::parse(): too few arguments.\n";
    }

    Rserve::debug "buf = $buf\n";
    Rserve::debug "offset = $offset\n";

    use vars qw(@a);
    @a = ();

    my @names = ();
    my @na    = ();
    my @r     = split '', $buf;

    # foreach (@r) {print "[" . ord($_). ":". $_ . "]"};  print "\n";

    my $i = $offset;
    my $eoa;

    Rserve::debug "i = $i\n";

    # some simple parsing - just skip attributes and assume short responses
    my $ra = Rserve::funclib::int8( \@r, $i );
    my $rl = Rserve::funclib::int24( \@r, $i + 1 );

    Rserve::debug "ra = $ra\n";
    Rserve::debug "rl = $rl\n";

    my $al;

    $i += 4;

    $offset = $eoa = $i + $rl;
    # Rserve::debug '[ '.Rserve::Parser::xtName($ra & 63).', length '.$rl.' ['.$i.' - '.$eoa."]\n";
    if ( ( $ra & 64 ) == 64 ) {
        die ('Fatal error: long packets are not supported (yet).');
    }
    if ( $ra > Rserve::XT_HAS_ATTR ) {
        # Rserve::debug '(ATTR*[';
        $ra &= ~Rserve::XT_HAS_ATTR;
        $al = Rserve::funclib::int24( \@r, $i + 1 );
        %attr = parse( $buf, $i );
        # Rserve::debug '])';
        $i += $al + 4;
    }

    for ($ra) {
	if ($ra == Rserve::XT_NULL) {
            Rserve::debug "Null";
            Rserve::debug "\n";
            @a = undef;
            # break;
        }
	
	elsif ($ra == Rserve::XT_VECTOR)  {    # generic vector
            Rserve::debug "Vector";
            Rserve::debug "\n";
            @a = ();
            while ( $i < $eoa ) {
                Rserve::debug "******* i = $i\n";
                #$a[] = parse($buf, &$i);
                print("recursive call to parse($buf, $i)\n");
                #my @parse_result = parse( $buf, \$i, @attr );
                #push( @a, \@parse_result );
                #print "*{" . Dumper(@parse_result) . "}*\n";
                #print Dumper(@a) . "\n";
                push( @a, parse( $buf, $i ) );
            }
            Rserve::debug Dumper(@a);
         # if the 'names' attribute is set, convert the plain array into a map
            if ( defined( $attr{'names'} ) ) {
                @names = $attr{'names'};
                @na    = ();
                my $n = length($a);
                for ( my $k = 0; $k < $n; $k++ ) {
                    $na[ $names[$k] ] = $a[$k];
                }
                @a = @na;
            }
            # break;
        }

	elsif ($ra == Rserve::XT_INT)  {
            Rserve::debug "Rserve::XT_INT\n";
            @a = Rserve::funclib::int32( \@r, $i );
            $i += 4;
            # break;
        }

	elsif ($ra == Rserve::XT_DOUBLE)  {
            Rserve::debug "Rserve::XT_DOUBLE\n";
            @a = Rserve::funclib::flt64( \@r, $i );
            $i += 8;
            # break;
        }

	elsif ($ra == Rserve::XT_BOOL)  {
            Rserve::debug "Rserve::XT_BOOL\n";
            my $v = Rserve::funclib::int8( \@r, $i++ );
            @a
                = ( $v == 1 )
                ? Rserve::TRUE
                : ( ( $v == 0 ) ? Rserve::FALSE : undef );
            # break;
        }

	elsif ($ra == Rserve::XT_SYMNAME)  {    # symbol
            Rserve::debug "Rserve::XT_SYMNAME\n";
            my $oi = $i;
            while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
                $i++;
            }
            @a = split '', substr( $buf, $oi, $i - $oi );
            # break; 
        }

	elsif ($ra == Rserve::XT_LANG_NOTAG or $ra == Rserve::XT_LIST_NOTAG ) 
        {                              # pairlist w/o tags
            Rserve::debug "Rserve::XT_LANG_NOTAG or Rserve::XT_LIST_NOTAG\n";
            @a = ();
            while ( $i < $eoa ) {
                # $a[] = self::parse($buf, &$i);
                push( @a, parse( $buf, $i, %attr ) );
            }
            # break;
        }

	elsif ($ra == Rserve::XT_LIST_TAG or $ra == Rserve::XT_LANG_TAG ) 
        {                              # pairlist with tags
            Rserve::debug "Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG\n";
            @a = ();
            while ( $i < $eoa ) {
                my $val = parse( $buf, $i );
                my $tag = parse( $buf, $i );
                $a[$tag] = $val;
            }
            # break;
        }

	elsif ($ra == Rserve::XT_ARRAY_INT)  {    # integer array
            Rserve::debug "Rserve::XT_ARRAY_INT\n";
            @a = ();
            while ( $i < $eoa ) {
                # $a[] = int32(@r, $i);
                push( @a, Rserve::funclib::int32( \@r, $i ) );
                $i += 4;
            }
            if ( scalar(@a) == 1 ) {
                @a = $a[0];
            }
            # If factor, then transform to characters
            #if (self::$factor_as_string and isset($attr['class'])) {
            if ( factor_as_string() and defined( $attr{'class'} ) ) {
                my $c = $attr{'class'};
                if ( $c eq 'factor' ) {
                    my $n      = scalar(@a);
                    my @levels = $attr{'levels'};
                    for ( my $k = 0; $k < $n; ++$k ) {
                        $i = $a[$k];
                        if ( $i < 0 ) {
                            $a[$k] = undef;
                        }
                        else {
                            $a[$k] = $levels[ $i - 1 ];
                        }
                    }
                }
            }
            # break;
        }

	elsif ($ra == Rserve::XT_ARRAY_DOUBLE)  {    # double array
            Rserve::debug "Rserve::XT_ARRAY_DOUBLE\n";
            @a = ();
            while ( $i < $eoa ) {
                #$a[] = flt64(@r, $i);
                push( @a, Rserve::funclib::flt64( \@r, $i ) );
                $i += 8;
            }
            if ( scalar(@a) == 1 ) {
                @a = $a[0];
            }
            # break;
        }

	elsif ($ra == Rserve::XT_ARRAY_STR)  {    # string array
            Rserve::debug "Rserve::XT_ARRAY_STR\n";
            @a = ();
            my $oi = $i;

            #Rserve::debug "i = $i\n";
            #Rserve::debug "eoa = $eoa\n";

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
            # break;
        }

	elsif ($ra == Rserve::XT_ARRAY_BOOL)  {    # boolean vector
            Rserve::debug "Rserve::XT_ARRAY_BOOL\n";
            my $n = Rserve::funclib::int32( \@r, $i );
            $i += 4;
            my $k = 0;
            @a = ();
            while ( $k < $n ) {
                my $v = Rserve::funclib::int8( \@r, $i++ );
                $a[ $k++ ]
                    = ( $v == 1 )
                    ? Rserve::TRUE
                    : ( ( $v == 0 ) ? Rserve::FALSE : undef );
            }
            if ( $n == 1 ) {
                @a = $a[0];
            }
            # break;
        }

	elsif ($ra == Rserve::XT_RAW)  {    # raw vector
            Rserve::debug "Rserve::XT_RAW\n";
            my $len = Rserve::funclib::int32( \@r, $i );
            $i += 4;
            @a = splice( @r, $i, $len );
            # break;
        }

        #  elsif ($ra == Rserve::XT_ARRAY_CPLX) {
        #   break;
        # }

	elsif ($ra == 48) {    # unimplemented type in Rserve
            my $uit = Rserve::funclib::int32( \@r, $i );
            warn "Note: result contains type #$uit unsupported by Rserve.<br/>";
            @a = undef;
            # break;
        }

	else {
            print(    'Warning: type '
		      . $ra
		      . ' is currently not implemented in the Perl client.' );
            @a = undef;
        }
    }    # end switch

    #if (self::$use_array_object) {
    if ( use_array_object() ) {
        # if ( is_array(@a) & @attr ) {
        if ( ( ref(@a) == 'ARRAY' ) & %attr ) {
            return new Rserve::RNative( @a, %attr );
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

sub parseDebug(@);

sub parseDebug(@) {
    Rserve::debug "parseDebug()\n";

    my $buf;
    my $offset;
    my @attr = undef;

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

    Rserve::debug "buf = $buf\n";
    Rserve::debug "offset = $offset\n";

    my @r = split '', $buf;

    my $i = $offset;

    my @a = ();

    # some simple parsing - just skip attributes and assume short responses
    my $ra = Rserve::funclib::int8( \@r, $i );
    my $rl = Rserve::funclib::int24( \@r, $i + 1 );

    Rserve::debug "ra = $ra\n";
    Rserve::debug "rl = $ra\n";

    $i += 4;

    my $eoa;
    $offset = $eoa = $i + $rl;

    my %result = ();

    $result{'type'}   = Rserve::Parser::xtName( $ra & 63 );
    $result{'length'} = $rl;
    $result{'offset'} = $i;
    $result{'eoa'}    = $eoa;
    if ( ( $ra & 64 ) == 64 ) {
        $result{'long'} = Rserve::TRUE;
        return %result;
    }
    if ( $ra > Rserve::XT_HAS_ATTR ) {

        $ra &= ~Rserve::XT_HAS_ATTR;
        my $al = Rserve::funclib::int24( \@r, $i + 1 );
        @attr = parseDebug( $buf, $i );
        $result{'attr'} = @attr;
        $i += $al + 4;
    }
    if ( $ra == Rserve::XT_NULL ) {
        return %result;
    }
    if ( $ra == Rserve::XT_VECTOR ) {    # generic vector
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = self::parseDebug($buf, &$i);
            push( @a, parseDebug( $buf, &$i ) );
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_SYMNAME ) {    # symbol
        my $oi = $i;
        while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
            $i++;
        }
        $result{'contents'} = substr( $buf, $oi, $i - $oi );
    }
    if ( $ra == Rserve::XT_LIST_NOTAG || $ra == Rserve::XT_LANG_NOTAG )
    {                                     # pairlist w/o tags
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = self::parseDebug($buf, &$i);
            push( @a, parseDebug( $buf, &$i ) );
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_LIST_TAG || $ra == Rserve::XT_LANG_TAG )
    {                                     # pairlist with tags
        @a = ();
        while ( $i < $eoa ) {
            my $val = parseDebug( $buf, &$i );
            my $tag = parse( $buf, $i );
            $a[$tag] = $val;
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_INT ) {    # integer array
        @a = ();
        while ( $i < $eoa ) {
            #$a[] = int32(@r, $i);
            push( @a, Rserve::funclib::int32( \@r, $i ) );
            $i += 4;
        }
        if ( length($a) == 1 ) {
            $result{'contents'} = $a[0];
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_DOUBLE ) {    # double array
        @a = ();
        while ( $i < $eoa ) {
            push( @a, Rserve::funclib::flt64( \@r, $i ) );
            $i += 8;
        }
        if ( length($a) == 1 ) {
            $result{'contents'} = $a[0];
        }
        $result{'contents'} = $a;
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
            $result{'contents'} = $a[0];
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_ARRAY_BOOL ) {    # boolean vector
        my $n = Rserve::funclib::int32( \@r, $i );
        $result{'size'} = $n;
        $i += 4;
        my $k = 0;
        @a = ();
        while ( $k < $n ) {
            my $v = Rserve::funclib::int8( \@r, $i++ );
  # $a[$k] = ($v === 1) ? Rserve::TRUE : (($v === 0) ? Rserve::FALSE : undef);
            $a[$k]
                = ( ( $v == 1 ) && is_number($v) )
                ? Rserve::TRUE
                : (
                ( ( $v == 0 ) && is_number($v) ) ? Rserve::FALSE : undef );
            ++$k;
        }
        if ( length($a) == 1 ) {
            $result{'contents'} = $a[0];
        }
        $result{'contents'} = $a;
    }
    if ( $ra == Rserve::XT_RAW ) {    # raw vector
        my $len = Rserve::funclib::int32( \@r, $i );
        $i += 4;
        $result{'size'} = $len;
        my $contents = join( '', substr( @r, $i, $len ) );
        $result{'contents'} = $contents;
    }
    if ( $ra == Rserve::XT_ARRAY_CPLX ) {
        $result{'not_implemented'} = Rserve::TRUE;
        # TODO: complex
    }
    if ( $ra == 48 ) {                # unimplemented type in Rserve
        my $uit = Rserve::funclib::int32( \@r, $i );
        $result{'unknownType'} = $uit;
    }
    return %result;
}

#public static function parseREXP($buf, $offset, $attr = NULL) {
sub parseREXP(@);
sub parseREXP(@) {

    Rserve::debug "parseREXP()\n";

    my $buf;
    my $offset;
    my @attr = undef;

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

    #Rserve::debug "buf = $buf\n";
    #Rserve::debug "offset = $offset\n";

    my @r = split '', $buf;
    my $i = $offset;

    my @v = ();

    # some simple parsing - just skip attributes and assume short responses
    my $ra = Rserve::funclib::int8( \@r, $i );
    my $rl = Rserve::funclib::int24( \@r, $i + 1 );

    Rserve::debug "ra = $ra\n";
    Rserve::debug "rl = $ra\n";

    # Rserve::debug Dumper($rl);

    #my $eoa = int24(0);
    my $eoa = 0;

    my $al, $i += 4;

    $offset = $eoa = $i + $rl;
    if ( ( $ra & 64 ) == 64 ) {
        die ('Fatal error: long packets are not supported (yet).');
    }

    if ( $ra > Rserve::XT_HAS_ATTR ) {
        $ra &= ~Rserve::XT_HAS_ATTR;
        $al = Rserve::funclib::int24( \@r, $i + 1 );
        @attr = parseREXP( $buf, $i );
        $i += $al + 4;
    }
    
    for ($ra) {
        if ($ra == Rserve::XT_NULL) {
            Rserve::debug "Rserve::XT_NULL\n";
            $a = new Rserve::REXP::Null();
            # break;
        }
        elsif ($ra == Rserve::XT_VECTOR) {    # generic vector
            Rserve::debug "Rserve::XT_VECTOR\n";
            @v = ();
            while ( $i < $eoa ) {
                # $v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, &$i ) );
            }
            $a = new Rserve::REXP::GenericVector();
            $a->setValues(@v);
            # break;
        }

        elsif ($ra == Rserve::XT_SYMNAME) {    # symbol
            Rserve::debug "Rserve::XT_SYMNAME\n";
            my $oi = $i;
            while ( $i < $eoa && ord( $r[$i] ) != 0 ) {
                $i++;
            }
            my $v = substr( $buf, $oi, $i - $oi );
            my $a = new Rserve::REXP::Symbol();
            $a->setValue($v);
            # break;
        }
        elsif ($ra ==  Rserve::XT_LIST_NOTAG or $ra == Rserve::XT_LANG_NOTAG )
        {                              # pairlist w/o tags
            Rserve::debug "Rserve::XT_LIST_NOTAG or Rserve::XT_LANG_NOTAG\n";
            @v = ();
            while ( $i < $eoa ) {
                #$v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, &$i ) );
            }
            my $clasz = ( $ra == Rserve::XT_LIST_NOTAG )
                ? 'Rserve::REXP::List'
                : 'Rserve::REXP::Language';
            $a = new $$clasz();
            $a->setValues($a);
            # break;
        }

        elsif ($ra == Rserve::XT_LIST_TAG or  $ra == Rserve::XT_LANG_TAG)
        {    # pairlist with tags
            Rserve::debug "Rserve::XT_LIST_TAG or Rserve::XT_LANG_TAG\n";
            my $clasz
                = ( $ra == Rserve::XT_LIST_TAG )
                ? 'Rserve::REXP::List'
                : 'Rserve::REXP::Language';
            my @v     = ();
            my @names = ();
            while ( $i < $eoa ) {
                #$v[] = self::parseREXP($buf, &$i);
                push( @v, parseREXP( $buf, &$i ) );
                # $names[] = self::parseREXP($buf, &$i);
                push( @names, parseREXP( $buf, &$i ) );
            }
            $a = new $$clasz();
            $a->setValues(@v);
            $a->setNames(@names);
            # break;
        }

        elsif ($ra == Rserve::XT_ARRAY_INT) {    # integer array
            Rserve::debug "Rserve::XT_ARRAY_INT\n";
            my @v = ();
            while ( my $i < $eoa ) {
                #$v[] = int32(@r, $i);
                push( @v, Rserve::funclib::int32( \@r, $i ) );
                $i += 4;
            }
            $a = new Rserve::REXP::Integer();
            $a->setValues(@v);
            # break;
        }

        elsif ($ra == Rserve::XT_ARRAY_DOUBLE) {    # double array
            Rserve::debug "Rserve::XT_ARRAY_DOUBLE\n";
            @v = ();
            while ( my $i < $eoa ) {
                # $v[] = flt64($r, $i);
                push( @v, Rserve::funclib::flt64( \@r, $i ) );
                $i += 8;
            }
            $a = new Rserve::REXP::Double();
            $a->setValues(@v);
            # break;
        }

        elsif ($ra == Rserve::XT_ARRAY_STR) {    # string array
            Rserve::debug "Rserve::XT_ARRAY_STR\n";
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
            # break;
        }

        elsif ($ra == Rserve::XT_ARRAY_BOOL) {    # boolean vector
            Rserve::debug "Rserve::XT_ARRAY_BOOL\n";
            my $n = Rserve::funclib::int32( \@r, $i );
            $i += 4;
            my $k  = 0;
            my @vv = ();
            while ( $k < $n ) {
                my $v = Rserve::funclib::int8( \@r, $i++ );
                $vv[$k]
                    = ( $v == 1 )
                    ? Rserve::TRUE
                    : ( ( $v == 0 ) ? Rserve::FALSE : undef );
                $k++;
            }
            $a = new Rserve::REXP::Logical();
            $a->setValues(@vv);
            # break;
        }

        elsif ($ra == Rserve::XT_RAW) {    # raw vector
            Rserve::debug "Rserve::XT_RAW\n";
            my $len = Rserve::funclib::int32( \@r, $i );
            $i += 4;
            my @v = substr( @r, $i, $len );
            my $a = new Rserve::REXP::Raw();
            $a->setValue(@v);
            # break;
        }

        elsif ($ra == Rserve::XT_ARRAY_CPLX) {
            Rserve::debug "Rserve::XT_ARRAY_CPLX\n";
            $a = Rserve::FALSE;
            # break;
        }

        elsif ($ra == 48) {    # unimplemented type in Rserve
            Rserve::debug "48\n";
            my $uit = Rserve::funclib::int32( \@r, $i );
        # echo "Note: result contains type #$uit unsupported by Rserve.<br/>";
            @a = undef;
            # break;
        }

        else {
            print(    'Warning: type '
                    . $ra
                    . ' is currently not implemented in the Perl client.' );
            @a = Rserve::FALSE;
        }
    }

    Rserve::debug "dumping a:\n";
    Rserve::debug Dumper(@a);
    Rserve::debug "done\n";

    #if ( scalar(@attr) && is_object(@a) ) {
    if ( scalar(@attr) && defined(@a) ) {
        @a->setAttributes(@attr);
    }

    return @a;
}

#public static function  xtName($xt) {

sub xtName($) {
    my $xt = shift;
    
    if    ($xt == Rserve::XT_NULL)         { return ('null'); }
    elsif ($xt == Rserve::XT_INT)          { return 'int'; }
    elsif ($xt == Rserve::XT_STR)          { return 'string'; }
    elsif ($xt == Rserve::XT_DOUBLE)       { return 'real'; }
    elsif ($xt == Rserve::XT_BOOL)         { return 'logical'; }
    elsif ($xt == Rserve::XT_ARRAY_INT)    { return 'int*'; }
    elsif ($xt == Rserve::XT_ARRAY_STR)    { return 'string*'; }
    elsif ($xt == Rserve::XT_ARRAY_DOUBLE) { return 'real*'; }
    elsif ($xt == Rserve::XT_ARRAY_BOOL)   { return 'logical*'; }
    elsif ($xt == Rserve::XT_ARRAY_CPLX)   { return 'complex*'; }
    elsif ($xt == Rserve::XT_SYM)          { return 'symbol'; }
    elsif ($xt == Rserve::XT_SYMNAME)      { return 'symname'; }
    elsif ($xt == Rserve::XT_LANG)         { return 'lang'; }
    elsif ($xt == Rserve::XT_LIST)         { return 'list'; }
    elsif ($xt == Rserve::XT_LIST_TAG)     { return 'list+T'; }
    elsif ($xt == Rserve::XT_LIST_NOTAG)   { return 'list/T'; }
    elsif ($xt == Rserve::XT_LANG_TAG)     { return 'lang+T'; }
    elsif ($xt == Rserve::XT_LANG_NOTAG)   { return 'lang/T'; }
    elsif ($xt == Rserve::XT_CLOS)         { return 'clos'; }
    elsif ($xt == Rserve::XT_RAW)          { return 'raw'; }
    elsif ($xt == Rserve::XT_S4)           { return 'S4'; }
    elsif ($xt == Rserve::XT_VECTOR)       { return 'vector'; }
    elsif ($xt == Rserve::XT_VECTOR_STR)   { return 'string[]'; }
    elsif ($xt == Rserve::XT_VECTOR_EXP)   { return 'expr[]'; }
    elsif ($xt == Rserve::XT_FACTOR)       { return 'factor'; }
    elsif ($xt == Rserve::XT_UNKNOWN)      { return 'unknown'; }
    else  {  
	# unknown type
	return '<? ' . $xt . '>'; 
    }
}

# * @param Rserve::REXP $value
#  * This function is not functional. Please use it only for testing
#public static function createBinary(Rserve::REXP $value) {
sub createBinary($);
sub createBinary($) {

    my $value = shift;
    # Current offset
    my $o        = 0;                   # Init with header size
    my $contents = '';
    my $type     = $value->getType();

    
    for ($type) {
	if ($type == Rserve::XT_S4 || $type == Rserve::XT_NULL) {
	    # break;
	}
	elsif ($type == Rserve::XT_INT) {
	    my $v = 0 + $value->at(0);
	    $contents .= Rserve::funclib::mkint32($v);
	    $o += 4;
	    # break;
	}
	elsif ($type == Rserve::XT_DOUBLE) {
	    my $v = 0.0 + $value->at(0);
	    $contents .= Rserve::funclib::mkfloat64($v);
	    $o += 8;
	    # break;
	}
	elsif ($type == Rserve::XT_ARRAY_INT) {
	    my @vv = $value->getValues();
	    my $n  = scalar(@vv);
	    my $v;
	    for ( my $i = 0; $i < $n; ++$i ) {
		$v = $vv[$i];
		$contents .= Rserve::funclib::mkint32($v);
		$o += 4;
	    }
	    # break;
	}
	elsif ($type == Rserve::XT_ARRAY_BOOL) {
	    my @vv = $value->getValues();
	    my $n  = scalar(@vv);
	    my $v;
	    $contents .= Rserve::funclib::mkint32($n);
	    $o += 4;
	    if ($n) {
		for ( my $i = 0; $i < $n; ++$i ) {
		    $v = $vv[$i];
		    if ( !defined($v) ) {
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
	    # break;
	}
	elsif ($type == Rserve::XT_ARRAY_DOUBLE) {
	    my @vv = $value->getValues();
	    my $n  = scalar(@vv);
	    my $v;
	    for ( my $i = 0; $i < $n; ++$i ) {
		$v = 0.0 + $vv[$i];
		$contents .= Rserve::funclib::mkfloat64($v);
		$o += 8;
	    }
	    # break;
	}
	elsif ($type == Rserve::XT_RAW) {
	    my $v = $value->getValue();
	    my $n = $value->length();
	    $contents .= Rserve::funclib::mkint32($n);
	    $o += 4;
	    $contents .= $v;
	    # break;
	}
	elsif ($type == Rserve::XT_ARRAY_STR) {
	    my @vv = $value->getValues();
	    my $n  = scalar(@vv);
	    my $v;
	    for ( my $i = 0; $i < $n; ++$i ) {
		$v = $vv[$i];
		if ($v) {
		    if ( ord( substr($v, 0, 1) ) == 255 ) {
			$contents .= chr(255);
			++$o;
		    }
		    $contents .= $v . chr(0);
		    $o += length($v) + 1;
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
	    # break;
	}
	elsif ($type == Rserve::XT_LIST_TAG ||
	       $type == Rserve::XT_LIST_NOTAG || 
	       $type == Rserve::XT_LANG_TAG ||
	       $type == Rserve::XT_LANG_NOTAG ||
	       $type == Rserve::XT_LIST ||
	       $type == Rserve::XT_VECTOR ||     
	       $type == Rserve::XT_VECTOR_EXP ) 
	{
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
	    # break;
	}
    
	elsif ($type == Rserve::XT_SYMNAME or $type == Rserve::XT_STR) {
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
	    # break;
	}

	else {
	    # default for switch - handle this?
	    die "unknown type";
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
    push( @r, Rserve::funclib::mkint24($length) );
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
