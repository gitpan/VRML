package VRML;

require 5.000;
use strict;
use vars qw(@ISA $VERSION);
$VERSION="1.02";

sub new {
    my $class = shift;
    my ($version) = @_ ? @_ : 0;
    my $self;
    if ($version =~ /2\.0/ || $version == 2) {
	require VRML::VRML2;
	@ISA = qw(VRML::VRML2);
	$self = new VRML::VRML2;
    } elsif ($version =~ /1\./ || $version == 1) {
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1;
    } else {
	require VRML::VRML1;
	@ISA = qw(VRML::VRML1);
	$self = new VRML::VRML1;
    }
    return bless $self, $class;
}

1;

__END__

=head1 NAME

VRML - VRML methods independent of specification (1.0 or 2.0)

=head1 SYNOPSIS

  use VRML;

  $vrml = new VRML(2);
  $vrml->browser('CosmoPlayer 1.0','Netscape');
  $vrml->at('-15 0 20');
  $vrml->box('5 3 1','yellow');
  $vrml->back;
  $vrml->print;
  $vrml->save;

  OR with the same result

  use VRML;

  VRML->new(2)
  ->browser('CosmoPlayer 1.0','Netscape')
  ->at('-15 0 20')->box('5 3 1','yellow')->back
  ->print->save;

=head1 DESCRIPTION

This module is usefull to generate VRML on WWW servers with CGI scripts
or/and to create dynamic abstact worlds. It is the top modul of six other
VRML moduls. 

=over 4

=item VRML::Base

contains basic functionality like 'print' and 'save'. (base class)

=item VRML::VRML1::Standard

is the pure implementation of VRML 1.0 nodes. All method names are intentically
with the VRML nodes. The parameter are sorted by usability.

=item VRML::VRML2::Standard

is the pure implementation of VRML 2.0 nodes. All method names are intentically
with the VRML nodes. The parameter are sorted by usability.


=item VRML::VRML1

combines one or more VRML 1.0 nodes to complex methods like geometry
methods with appearance. This modul accepts angles in degree and color names.
All method names are in lowercase and have the same names as in VRML::VRML2.
So users can switch between VRML 1.0 and VRML 2.0 source generation.
E.g. if C<$in{VRML}> contains '1' or '2' you could write 

C<new VRML($in{'VRML'})>

=item VRML::VRML2

combines one or more VRML 2.0 nodes to complex methods like geometry
methods with appearance. This modul accepts angles in degree and color names.
All method names are in lowercase and have the same names as in VRML::VRML1.
So users can switch between VRML 1.0 and VRML 2.0 source generation.
E.g. if C<$in{VRML}> contains '1' or '2' you could write 

C<new VRML($in{'VRML'})>

=item VRML::Color

contains the X11 color names and conversion functions.

=back

=head1 SEE ALSO

VRML::VRML1

VRML::VRML1::Standard

VRML::VRML2

VRML::VRML2::Standard

VRML::Base

VRML::Color

http://www.gfz-potsdam.de/~palm/vrmlperl/ for a description of F<VRML-modules> and how to obtain it.

=head1 BUGS

Some methods not tested very well at this time.

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

Homepage http://www.gfz-potsdam.de/~palm/

=cut
