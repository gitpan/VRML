package VRML;

require 5.000;

$VERSION="0.91"; warn $VERSION if 0;

sub new {
    my $class = shift;
    my ($version) = @_ ? @_ : 0;
    my $self;
    if ($version == 2 || $version =~ /2.0/) {
	$::content_type = "model/vrml";
	require VRML::VRML2;
	@ISA = qw(VRML::VRML2);
	$self = new VRML::VRML2;
    } elsif ($version == 1 || $version =~ /1.0/) {
	$::content_type = "x-world/x-vrml";
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1;
    } else {
	$::content_type = "x-world/x-vrml";
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1;
    }
    return bless $self, $class;
}

1;

__END__

=head1 NAME

VRML - implements VRML Nodes independent of specification (1.x or 2.0)

=head1 SYNOPSIS

  use VRML;

  $vrml = new VRML;
  $vrml->browser('Netscape+Live3D');
  $vrml->at('5 3 1');
  $vrml->cube('-50 -10 0','yellow');
  $vrml->back;
  $vrml->print;
  
  OR with the same result
  
  use VRML;

  VRML
  ->browser('Netscape+Live3D')
  ->at('5 3 1')->cube('-50 -10 0','yellow')->back
  ->print;

=head1 DESCRIPTION

=over 4

=item *
$content_type; # for CGI scripts only

content_type is C<'x-world/x-vrml'> for VRML 1.0

or C<'model/vrml'> for VRML 2.0

=back

=head1 SEE ALSO

VRML::VRML1

VRML::VRML1::Standard

VRML::VRML2

VRML::VRML2::Standard

VRML::Basic

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut
