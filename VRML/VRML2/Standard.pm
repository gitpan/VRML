package VRML::VRML2::Standard;

require 5.000;
use strict;
require VRML::Basic;
@VRML::VRML2::Standard::ISA = qw(VRML::Basic);

# $VERSION = "0.91";
$::debug = 0 unless defined $::debug;

=head1 NAME

VRML::VRML2::Standard.pm - implements nodes the VRML 2.0 standard

=head1 SYNOPSIS

    use VRML::VRML2::Standard;

=head1 DESCRIPTION

Following nodes are currently implemented.

[C<Grouping Nodes>] 
[C<Special Groups>] 
[C<Common Nodes>]

[C<Geometry>] 
[C<Geometric Properties>]
[C<Appearance>] 

[C<Sensors>]
[C<Bindable Nodes>] 

=cut

#####################################################################
#                        VRML Implementation                        #
#####################################################################

=head2 Grouping Nodes

I<These nodes NEED> C<End> !

=over 4

=cut

#--------------------------------------------------------------------

=item Anchor

C<Anchor($url, $description, $parameter, $bboxSize, $bboxCenter)>

$parameter works only with I<some> browsers

=cut

sub Anchor {
    my $self = shift;
    my ($url, $description, $parameter, $bboxSize, $bboxCenter) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Anchor {\n";
    $vrml .= $self->{'TAB'}."    url	$url\n";
    $vrml .= $self->{'TAB'}."    description	\"$description\"\n" if defined $description;
    $vrml .= $self->{'TAB'}."    parameter	\"$parameter\"\n" if $parameter;
    $vrml .= $self->{'TAB'}."    bboxSize	$bboxSize\n" if $bboxSize;
    $vrml .= $self->{'TAB'}."    bboxCenter	$bboxCenter\n" if $bboxCenter;
    $vrml .= $self->{'TAB'}."    children [\n";
    $self->{'TAB'} .= "\t";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Group

C<Group($comment)>

=cut

sub Group {
    my $self = shift;
    my ($comment) = @_;
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."Group {$comment\n";
    $vrml .= $self->{'TAB'}."    children [\n";
    $self->{'TAB'} .= "\t";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Transform

C<Transform($translation, $rotation, $scale, $scaleOrientation, $center)>

$translation is a SFVec3f

$rotation is a SFRotation

$scale is a SFVec3f

$scaleOrientation is a SFRotation

$center is a SFVec3f

=cut

sub Transform {
    my $self = shift;
    my ($translation, $rotation, $scale, $scaleOrientation, $center, $bboxSize, $bboxCenter) = @_;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    $self->xyz(split(/\s+/,$translation)) if defined $translation;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Transform {\n";
    $vrml .= $self->{'TAB'}."    translation	$translation\n" if $translation;
    $vrml .= $self->{'TAB'}."    rotation	$rotation\n" if $rotation;
    $vrml .= $self->{'TAB'}."    scale		$scale\n" if $scale;
    $vrml .= $self->{'TAB'}."    scaleOrientation	$scaleOrientation\n" if $scaleOrientation;
    $vrml .= $self->{'TAB'}."    center		$center\n" if $center;
    $vrml .= $self->{'TAB'}."    bboxSize	$bboxSize\n" if $bboxSize;
    $vrml .= $self->{'TAB'}."    bboxCenter	$bboxCenter\n" if $bboxCenter;
    $vrml .= $self->{'TAB'}."    children [\n";
    $self->{'TAB'} .= "\t";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Special Groups

=over 4

=cut

#--------------------------------------------------------------------

=item Inline

C<Inline($url, $bboxSize, $bboxCenter)>

=cut

sub Inline {
    my $self = shift;
    my $vrml = "";
    my ($url, $bboxSize, $bboxCenter) = @_;
    $vrml = $self->{'TAB'}."Inline {\n";
    $vrml .= $self->{'TAB'}."	url	$url\n";
    $vrml .= $self->{'TAB'}."	bboxSize $bboxSize\n" if $bboxSize;
    $vrml .= $self->{'TAB'}."	bboxCenter $bboxCenter\n" if $bboxCenter;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item LOD

C<LOD($range, $center)>

$range is a string with comma separated values

$center = SFVec3f

example: C<LOD('1, 2, 5', '0 0 0')>

=cut

sub LOD {
    my $self = shift;
    my ($range, $center) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."LOD {\n";
    $vrml .= $self->{'TAB'}."    range	[$range]\n" if $range;
    $vrml .= $self->{'TAB'}."    center	$center\n" if $center;
    $vrml .= $self->{'TAB'}."    level [\n";
    $self->{'TAB'} .= "\t";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Switch

C<Switch($whichChoice, $comment)>

=cut

sub Switch {
    my $self = shift;
    my ($whichChoice, $comment) = @_;
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."Switch {$comment\n";
    $vrml .= $self->{'TAB'}."    whichChoice $whichChoice\n" if defined $whichChoice;
    $vrml .= $self->{'TAB'}."    choice [\n";
    $self->{'TAB'} .= "\t";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Common Nodes

=over 4

=cut

#--------------------------------------------------------------------

=item DirectionalLight

C<DirectionalLight($direction, $intensity, $ambientIntensity, $color, $on)>

=cut

sub DirectionalLight {
    my $self = shift;
    my ($direction, $intensity, $ambientIntensity, $color, $on) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."DirectionalLight {\n";
    $vrml .= $self->{'TAB'}."	direction	$direction\n" if $direction;
    $vrml .= $self->{'TAB'}."	intensity	$intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	ambientIntensity	$ambientIntensity\n" if $ambientIntensity;
    $vrml .= $self->{'TAB'}."	color	$color\n" if $color;
    $vrml .= $self->{'TAB'}."	on	$on\n" if $on;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item PointLight

C<PointLight($location, $intensity, $color, $on)>

=cut

sub PointLight {
    my $self = shift;
    my ($location, $intensity, $ambientIntensity, $color, $on) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."PointLight {\n";
    $vrml .= $self->{'TAB'}."	location	$location\n" if $location;
    $vrml .= $self->{'TAB'}."	intensity	$intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	ambientIntensity	$ambientIntensity\n" if $ambientIntensity;
    $vrml .= $self->{'TAB'}."	color	$color\n" if $color;
    $vrml .= $self->{'TAB'}."	on	$on\n" if $on;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item SpotLight

C<SpotLight($location, $direction, $intensity, $color, $on)>

=cut

sub SpotLight {
    my $self = shift;
    my ($location, $direction, $intensity, $color, $on) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."SpotLight {\n";
    $vrml .= $self->{'TAB'}."	location	$location\n" if $location;
    $vrml .= $self->{'TAB'}."	direction	$direction\n" if $direction;
    $vrml .= $self->{'TAB'}."	intensity	$intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	color	$color\n" if $color;
    $vrml .= $self->{'TAB'}."	on	$on\n" if $on;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Sound

C<Sound($source, $location, $direction, $intensity, $maxFront, $maxBack, $minFront, $minBack, $priority, $spatialize)>

=cut

sub Sound {
    my $self = shift;
    my ($source, $location, $direction, $intensity, $maxFront, $maxBack, $minFront, $minBack, $priority, $spatialize) = @_;
    my $vrml = $self->{'TAB'}."Sound {\n";
    $vrml .= $self->{'TAB'}."	location	$location\n" if $location;
    $vrml .= $self->{'TAB'}."	direction	$direction\n" if $direction;
    $vrml .= $self->{'TAB'}."	intensity	$intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	maxFront	$maxFront\n" if $maxFront;
    $vrml .= $self->{'TAB'}."	maxBack		$maxBack\n" if $maxBack;
    $vrml .= $self->{'TAB'}."	minFront	$minFront\n" if $minFront;
    $vrml .= $self->{'TAB'}."	minBack		$minBack\n" if $minBack;
    $vrml .= $self->{'TAB'}."	priority	$priority\n" if $priority;
    $vrml .= $self->{'TAB'}."	spatialize	$spatialize\n" if $spatialize;
    if (defined $source) {
	if (ref($source) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	source ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$source;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	source $source\n";
	}
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item AudioClip

C<AudioClip($url, $description, $loop, $pitch, $startTime, $stopTime)>

=cut

sub AudioClip {
    my $self = shift;
    my $vrml = "";
    my ($url, $description, $loop, $pitch, $startTime, $stopTime) = @_;
    $vrml = $self->{'TAB'}."AudioClip {\n";
    $vrml .= $self->{'TAB'}."	url		\"$url\"\n" if $url;
    $vrml .= $self->{'TAB'}."	description	\"$description\"\n" if defined $description;
    $vrml .= $self->{'TAB'}."	loop		$loop\n" if defined $loop;
    $vrml .= $self->{'TAB'}."	pitch		$pitch\n" if $pitch;
    $vrml .= $self->{'TAB'}."	startTime	$startTime\n" if $startTime;
    $vrml .= $self->{'TAB'}."	stopTime	$stopTime\n" if $stopTime;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item WorldInfo

C<WorldInfo($title, $info)>

=cut

sub WorldInfo {
    my $self = shift;
    my ($title, $info) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."WorldInfo {\n";
    $vrml .= $self->{'TAB'}."	title	\"$title\"\n" if $title;
    $vrml .= $self->{'TAB'}."	info	\"$info\"\n" if $info;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Shape

C<Shape($comment)>

=cut

sub Shape {
    my $self = shift;
    my ($geometry, $appearance) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Shape {\n";
    if (defined $appearance) {
	if (ref($appearance) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	appearance ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$appearance;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	appearance $appearance\n";
	}
    }
    if (defined $geometry) {
	if (ref($geometry) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	geometry ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$geometry;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	geometry $geometry\n";
	}
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Geometry

=over 4

=cut

#--------------------------------------------------------------------

=item Box

C<Box($width, $height, $depth)>

=cut

sub Box {
    my $self = shift;
    my ($width, $height, $depth) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Box {\n";
    $vrml .= $self->{'TAB'}."	size	$width $height $depth\n" if $width;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Cone

C<Cone($radius, $height, $side, $bottom)>

=cut

sub Cone {
    my $self = shift;
    my ($radius, $height, $side, $bottom) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Cone {\n";
    $vrml .= $self->{'TAB'}."	bottomRadius	$radius\n" if $radius;
    $vrml .= $self->{'TAB'}."	height	$height\n" if $height;
    $vrml .= $self->{'TAB'}."	side	$side\n"  if $side;
    $vrml .= $self->{'TAB'}."	bottom	$bottom\n"  if $bottom;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Cylinder

C<Cylinder($radius, $height, $top, $side, $bottom)>

=cut

sub Cylinder {
    my $self = shift;
    my ($radius, $height, $top, $side, $bottom) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Cylinder {\n";
    $vrml .= $self->{'TAB'}."	radius	$radius\n" if defined $radius;
    $vrml .= $self->{'TAB'}."	height	$height\n" if defined $height;
    $vrml .= $self->{'TAB'}."	top	$top\n"  if $top;
    $vrml .= $self->{'TAB'}."	side	$side\n"  if $side;
    $vrml .= $self->{'TAB'}."	bottom	$bottom\n"  if $bottom;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item IndexedFaceSet

C<IndexedFaceSet($coordIndex_ref, $colorIndex_ref, $normalIndex_ref, $texCoordIndex_ref)>

$coordIndex_ref is a reference of a list of point index strings
like C<'0 1 3 2', '2 3 5 4', ...>

$colorIndex_ref is a reference of a list of materials

$normalIndex_ref is a reference of a list of normals

$texCoordIndex_ref is a reference of a list of textures

=cut

sub IndexedFaceSet {
    my $self = shift;
    my ($coord, $coordIndex_ref, $color, $colorIndex_ref, $normal, $normalIndex_ref, $texCoord, $texCoordIndex_ref) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."IndexedFaceSet {\n";
    if (defined $coord) {
	if (ref($coord) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	coord ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$coord;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	coord $coord\n";
	}
    }
    if ($coordIndex_ref) {
	$vrml .= $self->{'TAB'}."	coordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$coordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if (defined $color) {
	if (ref($color) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	color ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$color;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	color $color\n" if $color;
	}
	$vrml .= $self->{'TAB'}."	colorPerVertex	FALSE\n"
    }
    if ($colorIndex_ref) {
	$vrml .= $self->{'TAB'}."	colorIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$colorIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($normalIndex_ref) {
	$vrml .= $self->{'TAB'}."	normalIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$normalIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($texCoordIndex_ref) {
	$vrml .= $self->{'TAB'}."	texCoordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$texCoordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item IndexedLineSet

C<IndexedLineSet($coordIndex_ref, $colorIndex_ref, $normalIndex_ref, $texCoordIndex_ref)>

$coordIndex_ref is a reference of a list of point index strings
like C<'0 1 3 2', '2 3 5 4', ...>

$colorIndex_ref is a reference of a list of materials

$normalIndex_ref is a reference of a list of normals

$texCoordIndex_ref is a reference of a list of textures

=cut

sub IndexedLineSet {
    my $self = shift;
    my ($coordIndex_ref, $colorIndex_ref, $normalIndex_ref, $texCoordIndex_ref) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."IndexedLineSet {\n";
    if ($coordIndex_ref) {
	$vrml .= $self->{'TAB'}."	coordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$coordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($colorIndex_ref) {
	$vrml .= $self->{'TAB'}."	colorIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$colorIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($normalIndex_ref) {
	$vrml .= $self->{'TAB'}."	normalIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$normalIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($texCoordIndex_ref) {
	$vrml .= $self->{'TAB'}."	texCoordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$texCoordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item PointSet

C<PointSet($numPoints, $startIndex)>

=cut

sub PointSet {
    my $self = shift;
    my ($numPoints, $startIndex) = @_;
    $startIndex = 0 unless defined $startIndex;
    my $vrml = "";
    $vrml = $self->{'TAB'}."PointSet {\n";
    $vrml .= $self->{'TAB'}."	startIndex	$startIndex\n" if $startIndex;
    $vrml .= $self->{'TAB'}."	numPoints	$numPoints\n" if $numPoints;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Sphere

C<Sphere($radius)>

$radius have to be > 0

=cut

sub Sphere {
    my $self = shift;
    my ($radius) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Sphere {\n";
    $vrml .= $self->{'TAB'}."	radius	$radius\n" if $radius;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Text

C<Text($string, $fontStyle, $length, $maxExtent)>

$length is a string ('LEFT','CENTER','RIGHT')

=cut

sub Text {
    my $self = shift;
    my ($string, $fontStyle, $length, $maxExtent) = @_;
    my $vrml = $self->{'TAB'}."Text {\n";
    $vrml .= $self->{'TAB'}."	string \"$string\"\n";
    if (defined $fontStyle) {
	if (ref($fontStyle) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	fontStyle ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$fontStyle;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	fontStyle $fontStyle\n";
	}
    }
    $vrml .= $self->{'TAB'}."	length $length\n" if $length;
    $vrml .= $self->{'TAB'}."	maxExtent $maxExtent\n" if $maxExtent;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Geometric Properties

=over 4

=cut

#--------------------------------------------------------------------

=item Coordinate

C<Coordinate(@point)>

@point is a list of points with strings like C<'1.0 0.0 0.0', '-1 2 0'>

=cut

sub Coordinate {
    my $self = shift;
    my (@point) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Coordinate {\n";
    $vrml .= $self->{'TAB'}."	point [\n";
    $vrml .= $self->{'TAB'}."\t\t";
    $vrml .= join(",\n$self->{'TAB'}\t\t",@point);
    $vrml .= "\n".$self->{'TAB'}."	]\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Color

C<Color(@color)>

@color is a list of colors with strings like C<'1.0 0.0 0.0', '-1 2 0'>

=cut

sub Color {
    my $self = shift;
    my (@color) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Color {\n";
    $vrml .= $self->{'TAB'}."	color [\n";
    $vrml .= $self->{'TAB'}."\t\t";
    $vrml .= join(",\n$self->{'TAB'}\t\t",@color);
    $vrml .= "\n".$self->{'TAB'}."	]\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Normal

C<Normal(@vector)>

@vector is a list of vectors with strings like C<'1.0 0.0 0.0', '-1 2 0'>

=cut

sub Normal {
    my $self = shift;
    my (@vector) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Normal {\n";
    $vrml .= $self->{'TAB'}."	vector [\n$self->{'TAB'}\t\t";
    $vrml .= join(",\n$self->{'TAB'}\t\t",@vector);
    $vrml .= "\n".$self->{'TAB'}."\t]\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}


#--------------------------------------------------------------------

=back

=head2 Appearance

=over 4

=cut

#--------------------------------------------------------------------

=item Appearance

C<Appearance>

=cut

sub Appearance {
    my $self = shift;
    my ($material, $texture, $textureTransform) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Appearance {\n";
    if (defined $material) {
	if (ref($material) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	material ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$material;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	material $material\n";
	}
    }
    if (defined $texture) {
	if (ref($texture) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	texture ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$texture;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	texture $texture\n";
	}
    }
    if (defined $textureTransform) {
	if (ref($textureTransform) eq "CODE") {
	    $vrml .= $self->{'TAB'}."	textureTransform ";
	    push @{$self->{'VRML'}}, $vrml;
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$textureTransform;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	    $vrml = "";
	} else {
	    $vrml .= $self->{'TAB'}."	textureTransform $textureTransform\n";
	}
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Fontstyle

C<FontStyle($size, $style, $family)>
defines the current font style for all subsequent C<Text> Nodes


$style can be 'NONE','BOLD','ITALIC'

$familiy can be 'SERIF','SANS','TYPEWRITER'

=cut

sub FontStyle {
    my $self = shift;
    my ($size, $style, $family) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."FontStyle {\n";
    $vrml .= $self->{'TAB'}."	size $size\n" if $size;
    $vrml .= $self->{'TAB'}."	style $style\n" if $style;
    $vrml .= $self->{'TAB'}."	family $family\n" if $family;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Material

C<Material(%materials)>

=cut

sub Material {
    my $self = shift;
    my (%materials) = @_;
    my $vrml = "";
    my ($key, $value);
    $vrml = $self->{'TAB'}."Material {\n";
    while(($key,$value) = each %materials) {
	$vrml .= $self->{'TAB'}."	$key	$value\n";
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item ImageTexture

C<ImageTexture($url)>

=cut

sub ImageTexture {
    my $self = shift;
    my ($url, $repeatS, $repeatT) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."ImageTexture {\n";
    $vrml .= $self->{'TAB'}."	url	$url\n";
    $vrml .= $self->{'TAB'}."	repeatS	FALSE\n" if defined $repeatS && !$repeatS;
    $vrml .= $self->{'TAB'}."	repeatT	FALSE\n" if defined $repeatT && !$repeatT;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item MovieTexture

C<MovieTexture($url)>

=cut

sub MovieTexture {
    my $self = shift;
    my ($url, $loop, $startTime, $stopTime, $repeatS, $repeatT) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."MovieTexture {\n";
    $vrml .= $self->{'TAB'}."	url	$url\n";
    $vrml .= $self->{'TAB'}."	loop	TRUE\n" if defined $loop && $loop;
    $vrml .= $self->{'TAB'}."	startTime	$startTime\n" if $startTime;
    $vrml .= $self->{'TAB'}."	stopTime	$stopTime\n" if $stopTime;
    $vrml .= $self->{'TAB'}."	repeatS	FALSE\n" if defined $repeatS && !$repeatS;
    $vrml .= $self->{'TAB'}."	repeatT	FALSE\n" if defined $repeatT && !$repeatT;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Sensors

=over 4

=cut

#--------------------------------------------------------------------

=item CylinderSensor

C<CylinderSensor($enabled, $maxAngle, $minAngle)>

=cut

sub CylinderSensor {
    my $self = shift;
    my ($enabled, $maxAngle, $minAngle) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."CylinderSensor {\n";
    $vrml .= $self->{'TAB'}."	enabled	FALSE\n" if defined $enabled && !$enabled;
    $vrml .= $self->{'TAB'}."	maxAngle	$maxAngle\n" if $maxAngle;
    $vrml .= $self->{'TAB'}."	minAngle	$minAngle\n" if $minAngle;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item PlaneSensor

C<PlaneSensor($enabled, $maxPosition, $minPosition, $offset, $autoOffset)>

=cut

sub PlaneSensor {
    my $self = shift;
    my ($enabled, $maxPosition, $minPosition, $offset, $autoOffset) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."PlaneSensor {\n";
    $vrml .= $self->{'TAB'}."	maxPosition	$maxPosition\n" if $maxPosition;
    $vrml .= $self->{'TAB'}."	minPosition	$minPosition\n" if $minPosition;
    $vrml .= $self->{'TAB'}."	offset	$offset\n" if $offset;
    $vrml .= $self->{'TAB'}."	autoOffset	FALSE\n" if defined $autoOffset && !$autoOffset;
    $vrml .= $self->{'TAB'}."	enabled	FALSE\n" if defined $enabled && !$enabled;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item SphereSensor

C<SphereSensor($enabled, $offset, $autoOffset)>

=cut

sub SphereSensor {
    my $self = shift;
    my ($enabled, $offset, $autoOffset) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."SphereSensor {\n";
    $vrml .= $self->{'TAB'}."	offset	$offset\n" if $offset;
    $vrml .= $self->{'TAB'}."	autoOffset	FALSE\n" if defined $autoOffset && !$autoOffset;
    $vrml .= $self->{'TAB'}."	enabled	FALSE\n" if defined $enabled && !$enabled;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item TimeSensor

C<TimeSensor($cycleInterval, $loop, $enabled)>

=cut

sub TimeSensor {
    my $self = shift;
    my ($cycleInterval, $loop, $enabled) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."TimeSensor {\n";
    $vrml .= $self->{'TAB'}."	cycleInterval	$cycleInterval\n" if $cycleInterval;
    $vrml .= $self->{'TAB'}."	loop	TRUE\n" if defined $loop && $loop;
    $vrml .= $self->{'TAB'}."	enabled	FALSE\n" if defined $enabled && !$enabled;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item TouchSensor

C<TouchSensor($eneabled)>

=cut

sub TouchSensor {
    my $self = shift;
    my ($enabled) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."TouchSensor {";
    $vrml .= $self->{'TAB'}." enabled FALSE " if defined $enabled && !$enabled;
    $vrml .= "}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Bindable Nodes

=over 4

=cut

#--------------------------------------------------------------------

=item Background

C<Background($backUrl, $bottomUrl, $topUrl, $leftUrl, $rightUrl, $frontUrl, $groundColor, $skyColor, $groundAngle, $skyAngle)>

=cut

sub Background {
    my $self = shift;
    my ($backUrl, $bottomUrl, $topUrl, $leftUrl, $rightUrl, $frontUrl, $groundColor, $skyColor, $groundAngle, $skyAngle) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB_VIEW'}."Background {\n";
    $vrml .= $self->{'TAB_VIEW'}."	backUrl	$backUrl\n" if $backUrl;
    $vrml .= $self->{'TAB_VIEW'}."	bottomUrl	$bottomUrl\n" if $bottomUrl;
    $vrml .= $self->{'TAB_VIEW'}."	topUrl	$topUrl\n" if $topUrl;
    $vrml .= $self->{'TAB_VIEW'}."	groundColor	$groundColor\n" if $groundColor;
    $vrml .= $self->{'TAB_VIEW'}."	groundAngle	$groundAngle\n" if $groundAngle;
    $vrml .= $self->{'TAB_VIEW'}."	skyColor	$skyColor\n" if $skyColor;
    $vrml .= $self->{'TAB_VIEW'}."	skyAngle	$skyAngle\n" if $skyAngle;
    $vrml .= $self->{'TAB_VIEW'}."}\n";
    push @{$self->{'VIEW'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item NavigationInfo

C<NavigationInfo($headlight, $type, $speed, $visibilityLimit, $avatarSize)>

=cut

sub NavigationInfo {
    my $self = shift;
    my ($headlight, $type, $speed, $visibilityLimit, $avatarSize) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."NavigationInfo {\n";
    $vrml .= $self->{'TAB'}."	headlight	$headlight\n" if $headlight;
    $vrml .= $self->{'TAB'}."	type	\"$type\"\n" if $type;
    $vrml .= $self->{'TAB'}."	speed	$speed\n" if defined $speed;
    $vrml .= $self->{'TAB'}."	visibilityLimit	$visibilityLimit\n" if defined $visibilityLimit;
    $vrml .= $self->{'TAB'}."	avatarSize	[ $avatarSize ]\n" if defined $avatarSize;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Viewpoint

C<Viewpoint($description, $position, $orientation, $fieldOfView, $jump)>

=cut

sub Viewpoint {
    my $self = shift;
    my ($description, $position, $orientation, $fieldOfView, $jump) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB_VIEW'}."Viewpoint {\n";
    $vrml .= $self->{'TAB_VIEW'}."	description	$description\n" if $description;
    $vrml .= $self->{'TAB_VIEW'}."	position	$position\n" if $position;
    $vrml .= $self->{'TAB_VIEW'}."	orientation	$orientation\n" if $orientation;
    $vrml .= $self->{'TAB_VIEW'}."	fieldOfView	$fieldOfView\n" if $fieldOfView;
    $vrml .= $self->{'TAB_VIEW'}."	jump	$jump\n" if $jump;
    $vrml .= $self->{'TAB_VIEW'}."}\n";
    push @{$self->{'VIEW'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 other

=over 4

=cut

#--------------------------------------------------------------------

=item ROUTE

C<ROUTE($from, $to)>

=cut

sub ROUTE {
    my $self = shift;
    my ($from, $to) = @_;
    my $vrml = $self->{'TAB'}."ROUTE $from TO $to\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item End

C<End($comment)>

$comment is optional

=cut

sub End {
    my $self = shift;
    my ($comment,$children) = @_;
    return $self->VRML_put("# ERROR: TAB < 0 !\n") unless $self->{'TAB'};
    chop($self->{'TAB'});
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml .= $self->{'TAB'}."    ]\n" if defined $children;
    $vrml .= $self->{'TAB'}."}$comment\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

sub EndTransform {
    my $self = shift;
    my ($comment) = @_;
    return $self->VRML_put("# ERROR: TAB < 0 !\n") unless $self->{'TAB'};
    chop($self->{'TAB'});
    $comment = $comment ? " # $comment" : "";
    my $vrml = $self->{'TAB'}."    ]\n";
    $vrml .= $self->{'TAB'}."}$comment\n";
    push @{$self->{'VRML'}}, $vrml;
    shift @{$self->{'XYZ'}};
    $self->VRML_put("# EndTransform ".join(', ',@{$self->{'XYZ'}[0]})."\n") if $::debug == 1;
    return $self if $self->{'SELF'};
    return $vrml;
}

1;

__END__

=back

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut


