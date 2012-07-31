# * Rserve client for Perl
# * Supports Rserve protocol 0103 only (used by Rserve 0.5 and higher)
# * Based on rserve-php by Clément TURBELIN
# * @author Djun Kim
# * Licensed under# GPL v2 or at your option v3

# * Rserve::Exception
# * @author Djun Kim

package Rserve::Exception;

sub new() {
  my $class = shift;
  my $message = shift;
  my $self = {
	      msg => $message,
	     };
  bless $self, $class;
  return $self;
}

sub getErrorMessage() {
  my $self = shift;
  return $self->{msg};
}

1;

