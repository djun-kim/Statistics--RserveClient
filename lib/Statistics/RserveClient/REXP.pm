# * Rserve client for Perl
# * @author Djun Kim
# * Based on Clément Turbelin's PHP client
# * Licensed under GPL v2 or at your option v3

# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# *
# * Developed using code from Simple Rserve client for PHP by Simon
# * Urbanek Licensed under GPL v2 or at your option v3

# * This code is inspired from Java client for Rserve (Rserve package
# * v0.6.2) developed by Simon Urbanek(c)

# * R Expression wrapper

#use warnings;
#use autodie;

package Statistics::RserveClient::REXP;

use Statistics::RserveClient;
use Statistics::RserveClient qw (:xt_types );

use Statistics::RserveClient::Parser;

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(setAttributes getAttribute hasAttribute attr);

#  * List of attributes associated with the R object
#  * @var Rserve_REXP_List

#protected $attr = NULL;
my $attr = undef;

sub new() {
    my $class = shift;
    my $self = { _attr => undef, };
    bless $self, $class;
    return $self;
}

#sub setAttributes(Rserve_REXP_List $attr) {
sub setAttributes($) {
    my $self    = shift;
    my $attrref = shift;
    my @attr    = @$attrref;
    @{ $self->{_attr} } = @attr;
    return @{ $self->{_attr} };
}

sub hasAttribute($) {
    my $self = shift;
    if ( @{ $self->{_attr} } ) {
        return Statistics::RserveClient::FALSE;
    }
}

sub getAttribute($) {
    my $self = shift;
    my $name = shift;
    if ( @{ $self->{_attr} } ) {
        return undef;
    }
    return @{ $self->{_attr} }->at($name);
}

sub attr() {
    my $self = shift;
    return @{ $self->{_attr} };
}

sub isVector()     { return Statistics::RserveClient::FALSE; }
sub isInteger()    { return Statistics::RserveClient::FALSE; }
sub isNumeric()    { return Statistics::RserveClient::FALSE; }
sub isLogical()    { return Statistics::RserveClient::FALSE; }
sub isString()     { return Statistics::RserveClient::FALSE; }
sub isSymbol()     { return Statistics::RserveClient::FALSE; }
sub isRaw()        { return Statistics::RserveClient::FALSE; }
sub isList()       { return Statistics::RserveClient::FALSE; }
sub isNull()       { return Statistics::RserveClient::FALSE; }
sub isLanguage()   { return Statistics::RserveClient::FALSE; }
sub isFactor()     { return Statistics::RserveClient::FALSE; }
sub isExpression() { return Statistics::RserveClient::FALSE; }

sub toHTML() {
    my $self = shift;
    return
          "<div class='rexp xt_"
        . $self->getType()
        . "'><span class='typename'>"
        . Statistics::RserveClient::Parser::xtName( $self->getType() )
        . "</span>"
        . $self->attrToHTML()
        . "</div>\n";
}

#protected function attrToHTML() {
sub attrToHTML() {
    my $self = shift;
    if ( $self->{_attr} ) {
        return
              "<div class='attributes'>"
            . @{ $self->{_attr} }->toHTML()
            . "</div>";
    }
}

sub getType() {
    return Statistics::RserveClient::XT_VECTOR;
}

1;
