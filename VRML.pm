package VRML;

require 5.000;

$content_type = "x-world/x-vrml";

$VERSION="0.85";
sub Version {
    my $self = shift;
    return $VERSION, $self;
}

sub new {
    my $class = shift;
    my ($version) = @_ ? @_ : 0;
    my $self;
    if ($version == 2 || $version =~ /2.0/) {
	$content_type = "model/vrml";
	require VRML::VRML2;
	@ISA = qw(VRML::VRML2);
	$self = new VRML::VRML2 ($version);
    } elsif ($version == 1.1 || $version =~ /1.1/) {
	$content_type = "x-world/x-vrml";
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1 ($version);
    } else {
	$content_type = "x-world/x-vrml";
	$version = 1;
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1 ($version);
    }
    return bless $self, $class;
}

__END__

=head1 NAME

VRML.pm - implements VRML primitives and extensions

=head1 SYNOPSIS

  use VRML;

  $vrml = new VRML (1.0);
  $vrml->browser('Live3D');
  $vrml->cube('5 3 1','-50 -10 0','yellow');
  $vrml->print;
  
  OR with the same result
  
  use VRML;

  VRML
  ->version(1.0)
  ->browser('Live3D')
  ->cube('5 3 1','-50 -10 0','yellow')
  ->print;

=head1 DESCRIPTION

=over 4

=item *
$VRML::content_type; # for CGI scripts only

content_type is C<'x-world/x-vrml'> for VRML 1.0 and 1.1

or C<'model/vrml'> for VRML 2.0

=back

=head1 SEE ALSO

VRML::VRML1

VRML::VRML1::Standard

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut
