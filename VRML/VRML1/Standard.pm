package VRML::VRML1::Standard;

require 5.000;
use strict;

# $VERSION = "0.88";
$VRML::VRML1::Standard::debug = 0;

=head1 NAME

VRML::VRML1::Standard.pm - implements nodes the VRML 1.x standard

=head1 SYNOPSIS

    use VRML::VRML1::Standard;

=head1 DESCRIPTION

Following nodes are currently implemented.

[C<Group Nodes>] 
[C<Geometry Nodes>] 
[C<Property Nodes>]

[C<Appearance Nodes>] 
[C<Transform Nodes>] 
[C<Common Nodes>] 

=cut

sub new {
    my $class = shift;
    my $tabs = shift;
    my $self = {};
    $self->{'TAB'} = defined $tabs ? "\t" x $tabs : "";
    $self->{'SELF'} = 1;
    $self->{'XYZ'}  = [[0,0,0]];
    $self->{'Xmax'} = 0;
    $self->{'Ymax'} = 0;
    $self->{'Zmax'} = 0;
    $self->{'Xmin'} = 0;
    $self->{'Ymin'} = 0;
    $self->{'Zmin'} = 0;
    $self->{'DX'} = 0;
    $self->{'DY'} = 0;
    $self->{'DZ'} = 0;
    return bless $self, $class;
}

#####################################################################
#               Methods to modify the VRML array                    #
#####################################################################

sub VRML_init {
    my $self = shift;
    my $vrml = shift;
    $self->{'VRML'} = [$vrml];
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_head {
    my $self = shift;
    my $vrml = shift;
    ${$self->{'VRML'}}[0] = "$vrml\n\n";
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_add {
    my $self = shift;
    my $vrml = shift;
    ${$self->{'VRML'}}[$#{$self->{'VRML'}}] .= $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_insert {
    my $self = shift;
    my $vrml = shift;
    my $last = pop @{$self->{'VRML'}};
    push @{$self->{'VRML'}}, $vrml;
    push @{$self->{'VRML'}}, $last;
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_trim {
    my $self = shift;
    my $pattern = shift;
    $pattern = "^\\s+" unless defined $pattern;
    $self->{'VRML'}[$#{$self->{'VRML'}}] =~ s/$pattern//o;
    return $self if $self->{'SELF'};
    return "";
}

sub VRML_swap {
    my $self = shift;
    my $element1 = pop @{$self->{'VRML'}};
    my $element2 = pop @{$self->{'VRML'}};
    push @{$self->{'VRML'}}, $element1;
    push @{$self->{'VRML'}}, $element2;
    return $self if $self->{'SELF'};
    return "";
}

sub VRML_put {
    my $self = shift;
    my $vrml = shift;
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_row {
    my $self = shift;
    my ($row) = @_;
    my $vrml = $self->{'TAB'}.$row;
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

sub VRML_pos {
    my $self = shift;
    return $#{$self->{'VRML'}};
}

sub VRML_comment {
    my $self = shift;
    my ($comment) = @_;
    $comment = defined $comment ? "# ".$comment : "#";
    push @{$self->{'VRML'}}, $comment;
    return $self if $self->{'SELF'};
    return $comment;
}

sub VRML_print {
    my $self = shift;
    for (@{$self->{'VRML'}}) {
	print ascii($_);
    }
    return $self if $self->{'SELF'};
    return "";
}

#--------------------------------------------------------------------

sub as_ascii {
    my $self = shift;
    my $vrml = "";
    for (@{$self->{'VRML'}}) { $vrml .= ascii($_) };
    return $vrml;
}

sub ascii {
    s/[\204\344\365]/ae/g;
    s/[\224\366]/oe/g;
    s/[\201\374]/ue/g;
    s/[\216\304]/Ae/g;
    s/[\231\305\326]/Oe/g;
    s/[\263\374]/Ue/g;
    s/[\257\337]/sz/g;
    s/[\000-\010\013-\037\177-\377]/_/g;
    return $_;
}

#sub as_utf8 {
#    my $self = shift;
#    my $vrml = "";
#    for (@{$self->{'VRML'}}) { $vrml .= utf8($_); }
#    return $vrml;
#}
#
#sub utf8 {
#    s/[\204\344\365]/\302\344/g;	# ae
#    s/[\224\366]/\302\366/g;		# oe
#    s/[\201\374]/\302\374/g;		# ue
#    s/[\216\304]/\302\304/g;		# Ae
#    s/[\231\305\326]/\302\326/g;	# Oe
#    s/[\263\334]/\302\334/g;		# Ue
#    s/[\257\337]/sz/g;			# sz
#    s/[\000-\010\013-\037]/_/g;
#    return $_;
#}

sub xyz {
    my $self = shift;
    return $self unless @_;
    ($self->{'DX'}, $self->{'DY'}, $self->{'DZ'}) = @_;
    ${$self->{'XYZ'}[0]}[0] += $self->{'DX'};
    ${$self->{'XYZ'}[0]}[1] += $self->{'DY'};
    ${$self->{'XYZ'}[0]}[2] += $self->{'DZ'};
    print "XYZ = ".join(', ',@{$self->{'XYZ'}[0]})."\n" if $VRML::VRML1::Standard::debug == 2;
    $self->{'Xmax'} = ${$self->{'XYZ'}[0]}[0] if $self->{'Xmax'} < ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymax'} = ${$self->{'XYZ'}[0]}[1] if $self->{'Ymax'} < ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmax'} = ${$self->{'XYZ'}[0]}[2] if $self->{'Zmax'} < ${$self->{'XYZ'}[0]}[2];
    $self->{'Xmin'} = ${$self->{'XYZ'}[0]}[0] if $self->{'Xmin'} > ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymin'} = ${$self->{'XYZ'}[0]}[1] if $self->{'Ymin'} > ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmin'} = ${$self->{'XYZ'}[0]}[2] if $self->{'Zmin'} > ${$self->{'XYZ'}[0]}[2];
}

#####################################################################
#                        VRML Implementation                        #
#####################################################################

=head2 Group Nodes
These nodes NEED C<End> !

=over 4

=item Separator

C<Separator($comment)>

=cut

sub Separator {
    my $self = shift;
    my ($comment) = @_;
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."Separator {$comment\n";
    $self->{'TAB'} .= "\t";
    print "Separator ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Switch

C<Switch($comment)>

=cut

sub Switch {
    my $self = shift;
    my ($whichChild, $comment) = @_;
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."Switch {$comment\n";
    $vrml .= $self->{'TAB'}."	whichChild $whichChild\n\n" if defined $whichChild;
    $self->{'TAB'} .= "\t";
    print "Switch ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
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
    $self->{'TAB'} .= "\t";
    print "Group ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item WWWAnchor

C<WWWAnchor($url, $description, $target)>


$target works only with I<Live3D>

=cut

sub WWWAnchor {
    my $self = shift;
    my ($url, $description, $target) = @_;
    $url =~ s/"/\\"/g if defined $url;
    $description =~ s/"/\\"/g if defined $description;
    $target =~ s/"/\\"/g if defined $target;
    my $vrml = "";
    $vrml = $self->{'TAB'}."WWWAnchor {\n";
    $vrml .= $self->{'TAB'}."	name \"$url\"\n";
    $vrml .= $self->{'TAB'}."	description \"$description\"\n" if defined $description;
    $vrml .= $self->{'TAB'}."	target \"$target\"\n" if defined $target;
    $self->{'TAB'} .= "\t";
    print "WWWAnchor ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item LOD

C<LOD($range, $center)>

$range is a string with comma separated values

example: C<LOD('1, 2, 5', '0 0 0')>

=cut

sub LOD {
    my $self = shift;
    my ($range, $center) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."LOD {\n";
    $vrml .= $self->{'TAB'}."	range	[$range]\n" if $range;
    $vrml .= $self->{'TAB'}."	center	$center\n" if $center;
    $self->{'TAB'} .= "\t";
    print "LOD ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item SpinGroup

C<SpinGroup($axis, $radians)> is supported only be I<Live3D>

=cut

sub SpinGroup {
    my $self = shift;
    my ($axis, $radians) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."SpinGroup {\n";
    $vrml .= $self->{'TAB'}."	rotation $axis $radians\n";
    $self->{'TAB'} .= "\t";
    print "SpinGroup ",join(', ',@{$self->{'XYZ'}[0]}),"\n" if $VRML::VRML1::Standard::debug == 1;
    unshift @{$self->{'XYZ'}}, [@{$self->{'XYZ'}[0]}];
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=back

=head2 Geometry Nodes

=over 4

=item AsciiText

C<AsciiText($string, $width, $justification, $spacing)>

$justification is a string ('LEFT','CENTER','RIGHT')

=cut

sub AsciiText {
    my $self = shift;
    my ($string, $width, $justification, $spacing) = @_;
    $string =~ s/"/\\"/g if defined $string;
    my $vrml = "";
    $vrml = $self->{'TAB'}."AsciiText {\n";
    $vrml .= $self->{'TAB'}."	string \"$string\"\n" if $string;
    $vrml .= $self->{'TAB'}."	width $width\n" if $width;
    $vrml .= $self->{'TAB'}."	justification $justification\n" if $justification;
    $vrml .= $self->{'TAB'}."	spacing $spacing\n" if $spacing;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Cone

C<Cone($radius, $height, @parts)>

@parts is a list of strings ('SIDES', 'BOTTOM', 'ALL')

=cut

sub Cone {
    my $self = shift;
    my ($radius, $height, @parts) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Cone {\n";
    $vrml .= $self->{'TAB'}."	bottomRadius	$radius\n" if $radius;
    $vrml .= $self->{'TAB'}."	height	$height\n" if $height;
    $vrml .= $self->{'TAB'}."	parts	".join("|",@parts)."\n"  if @parts;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Cube

C<Cube($width, $height, $depth)>

=cut

sub Cube {
    my $self = shift;
    my ($width, $height, $depth) = @_;
#    $self->xyz($width, $height, $depth) if defined $width;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Cube {\n";
    $vrml .= $self->{'TAB'}."	width	$width\n" if $width;
    $vrml .= $self->{'TAB'}."	height	$height\n" if $height;
    $vrml .= $self->{'TAB'}."	depth	$depth\n" if $depth;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Cylinder

C<Cylinder($height, $radius, @parts)>

@parts is a list of strings ('SIDES', 'TOP', 'BOTTOM', 'ALL')

=cut

sub Cylinder {
    my $self = shift;
    my ($radius, $height, @parts) = @_; # parts = SIDE|TOP|BOTTOM
    my $vrml = "";
    $vrml = $self->{'TAB'}."Cylinder {\n";
    $vrml .= $self->{'TAB'}."	radius	$radius\n" if defined $radius;
    $vrml .= $self->{'TAB'}."	height	$height\n" if defined $height;
    $vrml .= $self->{'TAB'}."	parts	".join("|",@parts)."\n"  if @parts;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item IndexedFaceSet

C<IndexedFaceSet($coordIndex_ref, $materialIndex_ref, $normalIndex_ref, $textureCoordIndex_ref)>

$coordIndex_ref is a reference of a list of point index strings
like C<'0 1 3 2', '2 3 5 4', ...>

$materialIndex_ref is a reference of a list of materials

$normalIndex_ref is a reference of a list of normals

$textureCoordIndex_ref is a reference of a list of textures

=cut

sub IndexedFaceSet {
    my $self = shift;
    my ($coordIndex_ref, $materialIndex_ref, $normalIndex_ref, $textureCoordIndex_ref) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."IndexedFaceSet {\n";
    if ($coordIndex_ref) {
	$vrml .= $self->{'TAB'}."	coordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$coordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($materialIndex_ref) {
	$vrml .= $self->{'TAB'}."	materialIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$materialIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($normalIndex_ref) {
	$vrml .= $self->{'TAB'}."	normalIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$normalIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($textureCoordIndex_ref) {
	$vrml .= $self->{'TAB'}."	textureCoordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$textureCoordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item IndexedLineSet

C<IndexedLineSet($coordIndex_ref, $materialIndex_ref, $normalIndex_ref, $textureCoordIndex_ref)>

$coordIndex_ref is a reference of a list of point index strings
like C<'0 1 3 2', '2 3 5 4', ...>

$materialIndex_ref is a reference of a list of materials

$normalIndex_ref is a reference of a list of normals

$textureCoordIndex_ref is a reference of a list of textures

=cut

sub IndexedLineSet {
    my $self = shift;
    my ($coordIndex_ref, $materialIndex_ref, $normalIndex_ref, $textureCoordIndex_ref) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."IndexedLineSet {\n";
    if ($coordIndex_ref) {
	$vrml .= $self->{'TAB'}."	coordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$coordIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($materialIndex_ref) {
	$vrml .= $self->{'TAB'}."	materialIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$materialIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($normalIndex_ref) {
	$vrml .= $self->{'TAB'}."	normalIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$normalIndex_ref);
	$vrml .= ", -1\n".$self->{'TAB'}."	]\n";
    }
    if ($textureCoordIndex_ref) {
	$vrml .= $self->{'TAB'}."	textureCoordIndex [\n";
	$vrml .= $self->{'TAB'}."\t\t";
	$vrml .= join(", -1,\n$self->{'TAB'}\t\t",@$textureCoordIndex_ref);
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

#--------------------------------------------------------------------

=back

=head2 Property Nodes

=over 4

=cut

#--------------------------------------------------------------------

=item Coordinate3

C<Coordinate3(@points)>

@points is a list of points with strings like C<'1.0 0.0 0.0', '-1 2 0'>

=cut

sub Coordinate3 {
    my $self = shift;
    my (@points) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Coordinate3 {\n";
    $vrml .= $self->{'TAB'}."	point [\n";
    $vrml .= $self->{'TAB'}."\t\t";
    $vrml .= join(",\n$self->{'TAB'}\t\t",@points);
    $vrml .= "\n".$self->{'TAB'}."	]\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Fontstyle

C<FontStyle($size, $style, $family)>
defines the current font style for all subsequent C<AsciiText>


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

#--------------------------------------------------------------------

=back

=head2 Appearance Nodes

=over 4

=cut

#--------------------------------------------------------------------

=item Material

C<Material(%materials)>

=cut

sub Material {
    my $self = shift;
    my (%materials) = @_;
    my $vrml = "";
    my ($key, $value, $i, $l);
    my $c = ",";
    $vrml = $self->{'TAB'}."Material {\n";
    while(($key,$value) = each %materials) {
	$vrml .= $self->{'TAB'}."	$key";
	if (ref($value)) {
	    $l = $#{$value};
	    $vrml .= " [";
	    for ($i=0; $i<=$l; $i++) {
		if ($i == $l) { $c = ""; }
		$vrml .= "\n$self->{'TAB'}\t\t";
		if (ref($value->[$i])) {
		    $vrml .= "$value->[$i][0]$c	# $value->[$i][1]";
		} else {
		    $vrml .= "$value->[$i]$c";
		}
	    }
	    $vrml .= "\n".$self->{'TAB'}."\t]\n";
	} else {
	    $vrml .= "	$value\n";
	}
    }
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item MaterialBinding

C<MaterialBinding($value)>


$value can be

    DEFAULT	Use default bindng
    OVERALL	Whole object has same material
    PER_PART	One material for each part of object
    PER_PART_INDEXED	One material for each part, indexed
    PER_FACE	One material for each face of object
    PER_FACE_INDEXED	One material for each face, indexed
    PER_VERTEX	One material for each vertex of object
    PER_VERTEX_INDEXED	One material for each vertex, indexed

=cut

sub MaterialBinding {
    my $self = shift;
    my $vrml = "";
    $vrml = $self->{'TAB'}."MaterialBinding {\n";
    $vrml .= $self->{'TAB'}."	value	@_\n";
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
    $vrml .= $self->{'TAB'}."\tvector [\n$self->{'TAB'}\t\t";
    $vrml .= join(",\n$self->{'TAB'}\t\t",@vector);
    $vrml .= "\n".$self->{'TAB'}."\t]\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item NormalBinding

C<NormalBinding($value)>

$value is the same as C<MaterialBinding>

=cut

sub NormalBinding {
    my $self = shift;
    my $vrml = "";
    $vrml = $self->{'TAB'}."NormalBinding {\n";
    $vrml .= $self->{'TAB'}."	value	@_\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Texture2

C<Texture2($value)>

=cut

sub Texture2 {
    my $self = shift;
    my ($filename, $wrapS, $wrapT) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Texture2 {\n";
    $vrml .= $self->{'TAB'}."	filename	\"$filename\"\n";
    $vrml .= $self->{'TAB'}."	wrapS	CLAMP\n" if $wrapS;
    $vrml .= $self->{'TAB'}."	wrapT	CLAMP\n" if $wrapT;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 Transform Nodes

=over 4

=cut

#--------------------------------------------------------------------

=item Transform

C<Transform($translation, $rotation, $scaleFactor, $scaleOrientation, $center)>

$translation is a string like "0 1 -2"

$rotation is a string like "0 0 1 1.57"

$scaleFactor is a string like "1 1 1"

$scaleOrientation is a string like "0 0 1 0"

$center is a string like "0 0 0"

=cut

sub Transform {
    my $self = shift;
    my ($translation, $rotation, $scaleFactor, $scaleOrientation, $center) = @_;
    $self->xyz(split(/\s+/,$translation)) if defined $translation;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Transform {\n";
    $vrml .= $self->{'TAB'}."	translation $translation\n" if $translation;
    $vrml .= $self->{'TAB'}."	rotation $rotation\n" if $rotation;
    $vrml .= $self->{'TAB'}."	scaleFactor $scaleFactor\n" if $scaleFactor;
    $vrml .= $self->{'TAB'}."	scaleOrientation $scaleOrientation\n" if $scaleOrientation;
    $vrml .= $self->{'TAB'}."	center $center\n" if $center;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Rotation

C<Rotation($rotation)>

$rotation is a string like "0 0 1 1.57"

This node is not supported under VRML 2.0

F<use> C<Transform>

=cut

sub Rotation {
    my $self = shift;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Rotation {\n";
    $vrml .= $self->{'TAB'}."	rotation @_\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Scale

C<Scale($scaleFactor)>

$scaleFactor is a string like "1 1 1"

This node is not supported under VRML 2.0

F<use> C<Transform>

=cut

sub Scale {
    my $self = shift;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Scale {\n";
    $vrml .= $self->{'TAB'}."	scaleFactor @_\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Translation

C<Translation($translation)>

$translation is a string like "0 1 -2"

This node is not supported under VRML 2.0

F<use> C<Transform>

=cut

sub Translation {
    my $self = shift;
    my $vrml = "";
    $vrml = $self->{'TAB'}."Translation {\n";
    $vrml .= $self->{'TAB'}."	translation @_\n";
    $vrml .= $self->{'TAB'}."}\n";
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

=item PerspectiveCamera

C<PerspectiveCamera($position, $orientation, $heightAngle, $focalDistance, $nearDistance, $farDistance)>

=cut

sub PerspectiveCamera {
    my $self = shift;
    my ($position, $orientation, $heightAngle, 
	$focalDistance, $nearDistance, $farDistance) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."PerspectiveCamera {\n";
    $vrml .= $self->{'TAB'}."	position	$position\n" if $position;
    $vrml .= $self->{'TAB'}."	orientation	$orientation\n" if $orientation;
    $vrml .= $self->{'TAB'}."	heightAngle	$heightAngle\n" if $heightAngle;
    $vrml .= $self->{'TAB'}."	focalDistance	$focalDistance\n" if $focalDistance;
    $vrml .= $self->{'TAB'}."	nearDistance	$nearDistance\n" if $nearDistance;
    $vrml .= $self->{'TAB'}."	farDistance	$farDistance\n" if $farDistance;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item OrthographicCamera

C<OrthographicCamera($position, $orientation, $height, $focalDistance, $nearDistance, $farDistance)>

=cut

sub OrthographicCamera {
    my $self = shift;
    my ($position, $orientation, $height, 
	$focalDistance, $nearDistance, $farDistance) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."OrthographicCamera {\n";
    $vrml .= $self->{'TAB'}."	position	$position\n" if $position;
    $vrml .= $self->{'TAB'}."	orientation	$orientation\n" if $orientation;
    $vrml .= $self->{'TAB'}."	height		$height\n" if $height;
    $vrml .= $self->{'TAB'}."	focalDistance	$focalDistance\n" if $focalDistance;
    $vrml .= $self->{'TAB'}."	nearDistance	$nearDistance\n" if $nearDistance;
    $vrml .= $self->{'TAB'}."	farDistance	$farDistance\n" if $farDistance;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item DirectionalLight

C<DirectionalLight($direction, $intensity, $ambientIntensity, $color, $on)>

=cut

sub DirectionalLight {
    my $self = shift;
    my ($direction, $intensity, $ambientIntensity, $color, $on) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."DirectionalLight {\n";
    $vrml .= $self->{'TAB'}."	direction $direction\n" if $direction;
    $vrml .= $self->{'TAB'}."	intensity $intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	ambientIntensity $ambientIntensity\n" if $ambientIntensity;
    $vrml .= $self->{'TAB'}."	color $color\n" if $color;
    $vrml .= $self->{'TAB'}."	on $on\n" if $on;
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
    my ($location, $intensity, $color, $on) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."PointLight {\n";
    $vrml .= $self->{'TAB'}."	location $location\n" if $location;
    $vrml .= $self->{'TAB'}."	intensity $intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	color $color\n" if $color;
    $vrml .= $self->{'TAB'}."	on $on\n" if $on;
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
    $vrml .= $self->{'TAB'}."	location $location\n" if $location;
    $vrml .= $self->{'TAB'}."	direction $direction\n" if $direction;
    $vrml .= $self->{'TAB'}."	intensity $intensity\n" if $intensity;
    $vrml .= $self->{'TAB'}."	color $color\n" if $color;
    $vrml .= $self->{'TAB'}."	on $on\n" if $on;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

#--------------------------------------------------------------------

=back

=head2 other

=over 4

=item WWWInline

C<WWWInline($name, $bboxSize, $bboxCenter)>

=cut

sub WWWInline {
    my $self = shift;
    my $vrml = "";
    my ($name, $bboxSize, $bboxCenter) = @_;
    $name =~ s/"/\\"/g if defined $name;
    $vrml = $self->{'TAB'}."WWWInline {\n";
    $vrml .= $self->{'TAB'}."	name	\"$name\"\n";
    $vrml .= $self->{'TAB'}."	bboxSize $bboxSize\n" if $bboxSize;
    $vrml .= $self->{'TAB'}."	bboxCenter $bboxCenter\n" if $bboxCenter;
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item Info

C<Info($string, $comment)>

$comment is optional

=cut

sub Info {
    my $self = shift;
    my ($string, $comment) = @_;
    $string =~ s/"/\\"/g if defined $string;
    $comment = defined $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."Info {\n";
    $vrml .= $self->{'TAB'}."	string	\"$string\"$comment\n";
    $vrml .= $self->{'TAB'}."}\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item DEF

C<DEF($name)>

=cut

sub DEF {
    my $self = shift;
    my ($name) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."DEF \"$name\" ";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

=item USE

C<USE($name)>

=cut

sub USE {
    my $self = shift;
    my ($name) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."USE \"$name\"\n";
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
    my ($comment) = @_;
    return "# ERROR: TAB < 0 !\n" unless $self->{'TAB'};
    chop($self->{'TAB'});
    $comment = $comment ? " # $comment" : "";
    my $vrml = "";
    $vrml = $self->{'TAB'}."}$comment\n";
    shift @{$self->{'XYZ'}};
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

1;

__END__

=back

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut


