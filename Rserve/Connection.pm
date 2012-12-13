# * Rserve::Connection
# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * Based on rserve-php by Clément Turbelin
#
# * @author Djun Kim
# * Licensed under# GPL v2 or at your option v3

# Handle Connection and communicating with Rserve instance
# @author Djun Kim

#use warnings;
#use diagnostics;
#use autodie;

package Rserve::Connection;

#use Rserve;

use Data::Dumper;

use Exporter;

our @EXPORT = qw ( new init close evalString evalStringToFile DT_LARGE );

use Socket;

use Rserve::funclib qw( _rserve_make_packet );

use Rserve::Parser qw( parse );
use Rserve::Exception;
use Rserve::ParserException;

use constant PARSER_NATIVE         => 0;
use constant PARSER_REXP           => 1;
use constant PARSER_DEBUG          => 2;
use constant PARSER_NATIVE_WRAPPED => 3;

use constant DT_INT        => 1;
use constant DT_CHAR       => 2;
use constant DT_DOUBLE     => 3;
use constant DT_STRING     => 4;
use constant DT_BYTESTREAM => 5;
use constant DT_SEXP       => 10;
use constant DT_ARRAY      => 11;

# this is a flag saying that the contents is large (>0xfffff0) and
# hence uses 56-bit length field

use constant DT_LARGE => 64;

use constant CMD_login      => 0x001;
use constant CMD_voidEval   => 0x002;
use constant CMD_eval       => 0x003;
use constant CMD_shutdown   => 0x004;
use constant CMD_openFile   => 0x010;
use constant CMD_createFile => 0x011;
use constant CMD_closeFile  => 0x012;
use constant CMD_readFile   => 0x013;
use constant CMD_writeFile  => 0x014;
use constant CMD_removeFile => 0x015;
use constant CMD_setSEXP    => 0x020;
use constant CMD_assignSEXP => 0x021;

use constant CMD_setBufferSize => 0x081;
use constant CMD_setEncoding   => 0x082;

use constant CMD_detachSession    => 0x030;
use constant CMD_detachedVoidEval => 0x031;
use constant CMD_attachSession    => 0x032;

# control commands since 0.6-0
use constant CMD_ctrlEval     => 0x42;
use constant CMD_ctrlSource   => 0x45;
use constant CMD_ctrlShutdown => 0x44;

# errors as returned by Rserve
use constant ERR_auth_failed     => 0x41;
use constant ERR_conn_broken     => 0x42;
use constant ERR_inv_cmd         => 0x43;
use constant ERR_inv_par         => 0x44;
use constant ERR_Rerror          => 0x45;
use constant ERR_IOerror         => 0x46;
use constant ERR_not_open        => 0x47;
use constant ERR_access_denied   => 0x48;
use constant ERR_unsupported_cmd => 0x49;
use constant ERR_unknown_cmd     => 0x4a;
use constant ERR_data_overflow   => 0x4b;
use constant ERR_object_too_big  => 0x4c;
use constant ERR_out_of_mem      => 0x4d;
use constant ERR_ctrl_closed     => 0x4e;
use constant ERR_session_busy    => 0x50;
use constant ERR_detach_failed   => 0x51;

use Config;

my $_initialized = Rserve::FALSE;    #class variable

# get/setter for class variable
sub initialized(@) {
    $_initialized = shift if @_;
    return $_initialized;
}

my $_machine_is_bigendian = Rserve::FALSE;
# get/setter for class variable
sub machine_is_bigendian(;$) {
    $_machine_is_bigendian = shift if @_;
    return $_machine_is_bigendian;
}

#
# initialization of the library
#
sub init {
    # Rserve::debug "init()\n";
    my $self = shift;

    if ( initialized() ) {
        # Rserve::debug "already initialised...\n";
        return;
    }
    # Rserve::debug "initing...\n";
    # Rserve::debug "setting byte order...\n";
    if ( $Config{byteorder} eq '87654321' ) {
        machine_is_bigendian(Rserve::TRUE);
    }
    else {
        machine_is_bigendian(Rserve::FALSE);
    }

    initialized(Rserve::TRUE);
    # Rserve::debug "set initialized to true...\n";
    return $self;
}

#
# if port is 0 then host is interpreted as unix socket, otherwise host
# is the host to connect to (default is local) and port is the TCP
# port number (6311 is the default)

# public
#sub new($host='127.0.0.1', $port = 6311, $debug = FALSE) {
sub new {
    # Rserve::debug "new()\n";
    my $class = shift;
    my $self  = {
        socket       => undef,
        auth_request => Rserve::FALSE,
        auth_method  => undef,
        auth_key     => undef,
    };

    bless $self, $class;

    my $host  = '127.0.0.1';
    my $port  = 6311;
    my $debug = Rserve::FALSE;

    if ( @_ == 3 ) {
	Rserve::debug "3 args to Rserve::Connection::new()\n";
	( $host, $port, $debug ) = shift;
    }
    elsif ( @_ == 2 ) {
	Rserve::debug "2 args to Rserve::Connection::new()\n";
	( $host, $port ) = shift;
    }
    elsif ( @_ == 1 ) {
	Rserve::debug "1 args to Rserve::Connection::new()\n";
	$host = shift;
    }
    else {
        die("Bad number of arguments in creating connection\n");
    }

    Rserve::debug "host: $host\n";
    Rserve::debug "port: $port\n";

    my $proto = getprotobyname('tcp');
    my $inet_addr;
    my $paddr;

    # Rserve::debug "class = $class\n";

    # Rserve::debug "class = $class\n";
    if ( !$self->initialized() ) {
        # Rserve::debug "calling init from new()\n";
        init();
    }

    eval {
        $inet_addr = inet_aton($host)
            or die( Rserve::Exception->new("Can't resolve host $host") );

        if ( $port == 0 ) {
            socket( *SOCKET, Socket::AF_UNIX, Socket::SOCK_STREAM, 0 );
            $self->{socket} = *SOCKET;
        }
        else {
            socket( *SOCKET, Socket::AF_INET, Socket::SOCK_STREAM,
                Socket::IPPROTO_TCP );
            $paddr = sockaddr_in( $port, $inet_addr );

            $self->{socket} = *SOCKET;
        }
        if ( !$self->{socket} ) {

        }
    };
    if ($@) {
        die(Rserve::Exception->new(
                      "Unable to create socket<pre>"
                    . $@->getErrorMessage()
                    . "</pre>"
            )
        );
    }

    # Rserve::debug "created socket...\n";

    # socket_set_option($self->{socket}, SOL_TCP, SO_DEBUG,2);
    setsockopt( $self->{socket}, Socket::IPPROTO_TCP, Socket::SO_DEBUG, 2 );

    $paddr = sockaddr_in( $port, $inet_addr );

    eval { connect( $self->{socket}, $paddr ); };
    if ($@) {
        die Rserve::Exception->new(
            "Unable to connect" . $@->getErrorMessage() );
    }

    # Rserve::debug "connected...\n";

    my $buf = '';
    eval {
        (          defined( recv( $self->{socket}, $buf, 32, 0 ) )
                && length($buf) >= 32
                && substr( $buf, 0, 4 ) eq 'Rsrv' )
            or die Rserve::Exception->new(
            "Invalid response from server:" . $@ . "\n" );
    };
    if ($@) {
        warn $@->getErrorMessage();
    }

    my $rv = substr( $buf, 4, 4 );
    if ( $rv ne '0103' ) {
        die Rserve::Exception->new('Unsupported protocol version.');
    }

    # grab connection attributes (each is a quad)
    for ( my $i = 12; $i < 32; $i += 4 ) {
        my $attr = substr( $buf, $i, 4 );
        # Rserve::debug "attr = $attr\n";
        if ( $attr eq 'ARpt' ) {
            $self->{auth_request} = Rserve::TRUE;
            $self->{auth_method}  = 'plain';
        }
        elsif ( $attr eq 'ARuc' ) {
            $self->{auth_request} = Rserve::TRUE;
            $self->{auth_method}  = 'crypt';
        }
        if ( substr( $attr, 0, 1 ) eq 'K' ) {
            $self->{auth_key} = substr( $attr, 1, 3 );
        }
    }
    return $self;
}

sub DESTROY() {
    Rserve::Connection::close();
}

# Evaluate a string as an R code and return result
#  @param string $string
#  @param int $parser
#  @param REXP_List $attr

#public function evalString($string, $parser = self::PARSER_NATIVE, $attr=NULL) {
sub evalString() {
    my $self = shift;

    my $parser = PARSER_NATIVE;
    my %attr   = ();
    my $string = "";

    if ( @_ == 3 ) {
	Rserve::debug "3 args to evalString\n";
        ( $string, $parser, %attr ) = shift;
    }
    elsif ( @_ == 2 ) {
	Rserve::debug "2 args to evalString\n";
        ( $string, $parser ) = shift;
    }
    elsif ( @_ == 1 ) {
	Rserve::debug "1 arg to evalString\n";
        $string = shift;
    }

    Rserve::debug "parser = $parser\n";
    Rserve::debug "attr = $attr\n";
    Rserve::debug "string = $string\n";

    my %r = $self->command( Rserve::Connection::CMD_eval, $string );

    #Rserve::debug Dumper(%r);

    my $i = 20;
    if ( !$r{'is_error'} ) {
        my $buf = $r{'contents'};
        my @res = undef;
	if ($parser == PARSER_NATIVE) {
	    Rserve::debug "calling parser.parse()\n";
	    Rserve::debug "buf = $buf\n";
	    Rserve::debug "i = $i\n";
	    Rserve::debug "attr = \n";
	    Rserve::debug "  " . Dumper %attr . "\n";
	    Rserve::debug "\n";
	    
	    @res = Rserve::Parser::parse( $buf, $i, %attr );
	}
	elsif ($parser == PARSER_REXP) {
	    @res = Rserve::Parser::parseREXP( $buf, $i, %attr );
	}
	elsif ($parser == PARSER_DEBUG) {
	    @res = Rserve::Parser::parseDebug( $buf, $i, %attr );
	}
	elsif ($parser == PARSER_NATIVE_WRAPPED) {
	    my $old = Rserve::Parser->use_array_object();
	    Rserve::Parser->use_array_object(Rserve::TRUE);
	    @res = Rserve::Parser->parse( $buf, $i, %attr );
	    Rserve::Parser->use_array_object($old);
	}
	else {
	    die( new Rserve::Exception('Unknown parser') );
	    die('Unknown parser');
	}
	return @res;
    }

    # TODO: contents and code in exception
    #die(new Rserve::Exception('unable to evaluate'));
    my @loc = caller(1);
    warn("Rserve::Connection: Error while evaluating R query string at line $loc[2] of $loc[1].\n");
}

# Evaluate a query string and save the result to temporary file, returning the filepath.
#  @param string $string
#  @param string $tempDirectory
#  @param int $parser
#  @param REXP_List $attr

sub evalStringToFile() {
    Rserve::debug ("evalStringToFile\n");

    my $self = shift;

    my $parser = PARSER_NATIVE;
    my %attr   = ();
    my $string = "";
    my $filepath = "";

    if ( @_ == 4 ) {
	Rserve::debug "4 args to evalStringToFile\n";
        $string = $_[0];
        $filepath = $_[1];
        $parser = $_[2];
        %attr = $_[3];
    }
    elsif ( @_ == 3 ) {
	Rserve::debug "3 args to evalStringToFile\n";
        $string = $_[0];
        $filepath = $_[1];
        $parser = $_[2];
    }
    elsif ( @_ == 2 ) {
	Rserve::debug "2 args to evalStringToFile\n";
        $string = $_[0];
        $filepath = $_[1];
    }
    else {
	Rserve::debug "error - 1 arg to evalStringToFile\n";
	warn "Too few arguments to evalStringToFile()\n";
    }

    Rserve::debug "self = $self\n";
    Rserve::debug "string = $string;\n";
    Rserve::debug "filepath = $filepath\n";
    Rserve::debug "parser = $parser\n";
    Rserve::debug "attr = $attr\n";
    Rserve::debug "string = $string\n";

    @stream = $self->evalString($string, $parser, %attr);

    open BINARY, ">:raw", $filepath or die "Couldn't open $filepath: $!\n";
    foreach (@stream) { print BINARY $_}
    close BINARY;
}


#
# * Close the current connection
#
sub close() {
    my $self = shift;
    if ( $self->{socket} ) {
        return CORE::close($self->{socket});
    }
    return Rserve::TRUE;
}

#
#  send a command to R
#  @param int $command command code
#  @param string $v command contents
#
sub command() {
    my $self    = shift;
    my $command = shift;
    my $v       = shift;

    #Rserve::debug "v = $v\n";
    #Rserve::debug "make pkt..\n";
    my $pkt = Rserve::funclib::_rserve_make_packet( $command, $v );

    # Rserve::debug "pkt = $pkt\n";

    eval {
        #socket_send($self->{socket}, $pkt, length($pkt), 0);
        my $n = send( $self->{socket}, $pkt, 0 );
        #Rserve::debug "n = $n\n";
        die Rserve::Exception->new("Invalid (short) response from server:$!")
            if ( $n == 0 );
    };
    if ($@) {
        warn "Error on " . $self->{socket} . ":" . $@->getErrorMessage() . "\n";
        return Rserve::FALSE;
    }

    #Rserve::debug "sent pkt..\n";

    # get response
    return processResponse($self);
}


sub commandRaw() {
    my $self    = shift;
    my $cmd     = shift;
    my $v       = shift;

    my $n = length($v);

    # Rserve::debug "cmd: $cmd; string: $v, n=$n\n";

    # take next largest muliple of 4 to pad out string length
    $n = $n + ( ( $n % 4 ) ? ( 4 - $n % 4 ) : 0 );

    # [0]  (int) command
    # [4]  (int) length of the message (bits 0-31)
    # [8]  (int) offset of the data part
    # [12] (int) length of the message (bits 32-63)
    my $pkt = pack( "V V V V Z$n",
        ( $cmd, $n, 0, 0, $v ) );

    #Rserve::debug "pkt = $pkt\n";

    eval {
        #socket_send($self->{socket}, $pkt, length($pkt), 0);
        my $n = send( $self->{socket}, $pkt, 0 );
        #Rserve::debug "n = $n\n";
        die Rserve::Exception->new("Invalid (short) response from server:$!")
            if ( $n == 0 );
    };
    if ($@) {
        warn "Error: on " . $self->{socket} . ":" . $@->getErrorMessage() . "\n";
        return Rserve::FALSE;
    }

    #Rserve::debug "sent pkt..\n";

    # get response
    return processResponse($self);
}

sub processResponse($) {
    my $self = shift;
    my $n = 0;
    my $buf = "";
    eval {
        #Rserve::debug "receiving pkt..\n";
        ( defined( recv( $self->{socket}, $buf, 16, 0 ) )
                && length($buf) >= 16 )
            or die Rserve::Exception->new(
            'Invalid (short) response from server:');
        $n = length($buf);
        #Rserve::debug "n = $n\n";
    };
    if ($@) {
        warn $@->getErrorMessage();
    }

    # Rserve::debug "got response...$buf\n";

    my @b = split "", $buf;

    #foreach (@b) {print "[" . ord($_) . "]" }; print "\n";

    if ( $n != 16 ) {
        return Rserve::FALSE;
    }
    my $code = Rserve::funclib::int32( \@b, 0 );
    # Rserve::debug "code = $code\n";

    my $len = Rserve::funclib::int32( \@b, 4 );
    # Rserve::debug "len = $len\n";

    my $ltg = $len;
    while ( $ltg > 0 ) {
        #Rserve::debug " ltg = $ltg\n";
        #Rserve::debug " getting result..\n";
        my $buf2 = "";
        eval {
            # $n = socket_recv($self->{socket}, $buf2, $ltg, 0);
            ( defined( recv( $self->{socket}, $buf2, $ltg, 0 ) ) )
                or die Rserve::Exception->new(
                'error getting result from server:');
            $n = length($buf2);
            # Rserve::debug "  n = $n\n";
        };
        if ($@) {
            warn $@->getErrorMessage();
        }

        #Rserve::debug "buf = $buf\n";
        #Rserve::debug "len(buf) = ". length($buf) . "\n";
        #Rserve::debug "buf2 = $buf2\n";
        #Rserve::debug "n = $n\n";

        if ( $n > 0 ) {
            $buf .= $buf2;
            undef($buf2);
            $ltg -= $n;
        }
        else {
            last;
        }
    }

    #  Rserve::debug "code = $code\n";
    #  Rserve::debug "code & 15 = " . ($code & 15) . "\n";
    #  Rserve::debug "code error = " . (($code >> 24) & 127) . "\n";

    #Rserve::debug "buf = $buf\n";
    #foreach (split "", $buf) {print "[" . ord($_)."]"};
    #Rserve::debug "\n";

    my %r = (
        code       => $code,
        is_error   => ( ( $code & 15 ) != 1 ) ? Rserve::TRUE : Rserve::FALSE,
        'error'    => ( $code >> 24 ) & 127,
        'contents' => $buf
    );

    return (%r);
}

#
# Assign a value to a symbol in R
#  @param string $symbol name of the variable to set (should be compliant with R syntax !)
#  @param Rserve_REXP $value value to set
sub assign($$$) {
    my $self = shift;
    my $symbol = shift;
    my $value = shift;

    unless ($symbol->isa('Rserve::REXP::Symbol') ||
            $symbol->isa('Rserve::REXP::String')) {
        $symbol = '' . $symbol;
        my $s = new Rserve::REXP::Symbol($symbol);
        $symbol = $s;
    }
    unless ($value->isa('Rserve::REXP')) {
        die Rserve::Exception->new("value should be REXP object");
    }

    my $n = length($symbol->getValue());

    my $data = join('', Rserve::Parser::createBinary($value));
    # my @d = split '', $data;
    # foreach (@d) {print "[" . ord($_) . "]"};  print "\n";

    my $contents = '' . 
	   Rserve::funclib::mkint8(DT_STRING) . 
	     Rserve::funclib::mkint24($n+1) . $symbol->getValue() . chr(0) .
         Rserve::funclib::mkint8(DT_SEXP) . 
	     join('', Rserve::funclib::mkint24(length($data))) . $data;

    # my @c = split "", $contents;
    # foreach (@c) {print "[" . ord($_). ":". $_ . "]"};  print "\n";

    my %r = $self->commandRaw(Rserve::Connection::CMD_assignSEXP, $contents);
    die if $r{'is_error'};
}

1;

