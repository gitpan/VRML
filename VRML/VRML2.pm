package VRML::VRML2;
use strict "refs";

require 5.000;
use VRML::Color;
require VRML::VRML2::Standard;
@ISA = qw(VRML::VRML2::Standard);

# $VERSION="0.90";
$supported{'quote'} = "Live3D|WebFx";
$supported{'target'} = "Live3D|WebFx";
$supported{'frames'} = "Netscape|Mozilla|Internet Explorer|MSIE";

#--------------------------------------------------------------------

sub new {
    my $class = shift;
    my $version = shift;
    my $self = new VRML::VRML2::Standard;
    $self->{'browser'} = "";
    $self->{'content_type'} = "x-world/x-vrml";
    $self->{'version'} = 2;
    $self->VRML_head("#VRML V2.0 utf8");
    return bless $self, $class;
}

sub browser {
    my $self = shift;
    ($self->{'browser'}) = @_ if @_;
    $self->VRML_put("# Set Browser to: '$self->{'browser'}'\n");
    return $self;
}

#--------------------------------------------------------------------
#   VRML Grouping Methods
#--------------------------------------------------------------------
sub begin {
    my $self = shift;
    $self->transform(@_);
    return $self;
}

sub end {
    my $self = shift;
    $self->EndTransform($_[0],TRUE); #  close [ and {
    return $self;
}

sub group {
    my $self = shift;
    $self->Group(@_);
    return $self;
}

*at = *begin; 
warn &at if 0;

sub transform {
    my $self = shift;
    my ($transform_list) = shift;
    return $self->Transform unless $transform_list;
    @transform = ref($transform_list) ? @$transform_list : split(/\s*;\s*/,$transform_list);
    my ($item, $key, $value);
    my ($x,$y,$z,$rad,$t,$r,$f,$o,$c);
    foreach $item (@transform) {
	next if $item eq "";
	($key,$value) = ref($item) ? @$item : split(/\s*[=:]\s*/,$item);
	unless ($value) {
	    ($x,$y,$z) = split(/\s/,$key);
	    $x=0 unless defined $x;
	    $y=0 unless defined $y;
	    $z=0 unless defined $z;
	    $t = "$x $y $z";
	}
	MODE: {
	    if ($key =~ /^t/) { $t = $value; last MODE; }
	    if ($key =~ /^r/) { $r = $value; last MODE; }
	    if ($key =~ /^s.*or|^o/) { $o = $value; last MODE; }
	    if ($key =~ /^s|^f/) { $f = $value;	last MODE; }
	    if ($key =~ /^c/) { $c = $value; last MODE; }
	}
	if ($key =~ /^r/) {
	    ($x,$y,$z,$rad) = split(/\s/,$value);
	    unless ($rad) {
		$rad=$x;
		$x=0;
		$y=0;
		$z=1;
	    }
	    $rad *= $::pi/180 if abs($rad) > 2*$::pi;
	    $r = "$x $y $z $rad";
	}
    }
    $self->Transform($t,$r,$f,$o,$c);
    return $self;
}

#--------------------------------------------------------------------
#   VRML Methods
#--------------------------------------------------------------------

sub backgroundcolor {
    my $self = shift;
    my ($skyColorString, $groundColorString) = @_;
    my ($skyColor, $groundColor);
    ($groundColor, $groundColorString) = rgb_color($groundColorString);
    ($skyColor, $skyColorString) = rgb_color($skyColorString);
    $self->Background(undef, undef, undef, undef, undef, undef, $groundColor, $skyColor);
    return $self;
}

sub backgroundimage {
    my $self = shift;
    my ($backUrl, $bottomUrl, $topURL) = @_;
    $self->Background($backUrl, $bottomUrl, $topURL);
    return $self;
}

sub title {
    my $self = shift;
    my $title = shift;
    return $self->VRML_put(qq{# CALL: ->title("string")\n}) if defined $self->{'HELP'};
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $title =~ s/"/$quote/g;
    $self->WorldInfo($title);
    return $self;
}

sub info {
    my $self = shift;
    my ($info, $title) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $title =~ s/"/$quote/g if defined $title;
    $info =~ s/"/$quote/g if defined $info;
    $self->WorldInfo($title, $info);
    return $self;
}

#--------------------------------------------------------------------

sub cameras_begin {
    my $self = shift;
    my ($whichChild) = @_;
    $whichChild = (defined $whichChild && $whichChild > 0) ? $whichChild-1 : 0;
    $self->{'TAB_VIEW'} = $self->{'TAB'};
    $self->{'cameras_begin'} = $#{$self->{'VRML'}}+1 unless defined $self->{'cameras_begin'};
    return $self;
}

sub cameras_end {
    my $self = shift;
    chop($self->{'TAB_VIEW'});
    splice(@{$self->{'VRML'}}, $self->{'cameras_begin'}, 0, @{$self->{'VIEW'}});
    $self->{'VIEW'} = [];
    return $self;
}

sub auto_camera_set {
    my $self = shift;
    my $factor = shift;
    $factor = 1 unless defined $factor;
    if (defined $self->{'camera_set'}) {
	my $x = ($self->{'Xmax'}+$self->{'Xmin'})/2;
	my $y = ($self->{'Ymax'}+$self->{'Ymin'})/2;
	my $z = ($self->{'Zmax'}+$self->{'Zmin'})/2;
	my $dx = abs($self->{'Xmax'}-$x); # todo calculate angle
	my $dy = abs($self->{'Ymax'}-$y);
	my $dz = abs($self->{'Zmax'}-$z);
	my $dist = 0;
	$dist = $dx if $dx > $dist;
	$dist = $dy if $dy > $dist;
	$dist = $dz if $dz > $dist;
	my $offset = $#{$self->{'VIEW'}}+1;
	$self->camera_set("$x $y $z",$dist*$factor,60);
	@_ = splice(@{$self->{'VIEW'}}, $offset);
	splice(@{$self->{'VIEW'}}, $self->{'camera_set'}, $#_+1, @_);
    } else {
	$self->camera_set(@_);
    }
    return $self;
}

sub camera_set {
    my $self = shift;
    my ($center, $distance, $heightAngle) = @_;
    $self->{'camera_set'} = $#{$self->{'VIEW'}}+1 unless defined $self->{'camera_set'};
    my ($x, $y, $z) = split(/\s+/,$center) if defined $center;
    my ($dx, $dy, $dz) = defined $distance ? split(/\s+/,$distance) : (0,0,0);
    $x = 0 unless defined $x;
    $y = 0 unless defined $y;
    $z = 0 unless defined $z;
    $dx = 1 unless defined $dx;
    $dy = $dx unless defined $dy;
    $dz = $dx unless defined $dz;
    $self->camera("Front", "$x $y ".($z+$dz), "0 0 1 0",$heightAngle);
    $self->camera("Right", ($x+$dx)." $y $z", "0 1 0 90",$heightAngle);
    $self->camera("Back", "$x $y ".($z-$dz), "0 1 0 180",$heightAngle);
    $self->camera("Left", ($x-$dx)." $y $z", "0 1 0 -90",$heightAngle);
    $self->camera("Top", "$x ".($y+$dy)." $z", "1 0 0 -90",$heightAngle);
    $self->camera("Bottom", "$x ".($y-$dy)." $z", "1 0 0 90",$heightAngle);
    return $self;
}

sub camera {
    my $self = shift;
    my ($description,
	$position, $orientation, $fieldOfView, $jump) = @_;
    my ($x,$y,$z,$degree) = ref($orientation) ? @$orientation : split(/\s+/,$orientation);
    if (defined $degree) {
	$degree *= $::pi/180 if (abs($degree) > 2*$::pi);
	$orientation = "$x $y $z $degree";
    }
    $fieldOfView *= $::pi/180 if defined $fieldOfView && (abs($fieldOfView) > 2*$::pi);
    $self->Viewpoint($description, $position, $orientation, $fieldOfView, $jump);
    unless (defined $self->{'cameras_begin'}) {
	splice(@{$self->{'VRML'}}, @{$self->{'VRML'}}, 0, @{$self->{'VIEW'}});
	$self->{'VIEW'} = [];
    }
    return $self;
}

#--------------------------------------------------------------------

sub light {
    my $self = shift;
    my ($direction, $intensity, $color, $ambientIntensity, $on) = @_;
    $intensity /= 100 if defined $intensity && $intensity > 1;
    $self->DirectionalLight($direction, $intensity, $color, $ambientIntensity, $on);
    return $self;
}

#--------------------------------------------------------------------

sub anchor_begin {
    my $self = shift;
    my ($url, $description, $parameter) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $description =~ s/"/$quote/g if defined $description;
    $parameter =~ s/"/$quote/g if defined $parameter;
    undef $parameter if $self->{'browser'} !~ /$supported{'frames'}/i || $self->{'browser'} !~ /$supported{'target'}/i;
    $self->Anchor($url, $description, $parameter);
    return $self;
}

sub anchor_end {
    my $self = shift;
    $self->End($_[0],TRUE); #  close [ and {
    return $self;
}

#--------------------------------------------------------------------

sub line {
    my $self = shift;
    my ($from,$to,$radius,$appearance,$order) = @_;
    my ($x1,$y1,$z1) = ref($from) ? @$from : split(/\s+/,$from);
    my ($x2,$y2,$z2) = ref($to) ? @$to : split(/\s+/,$to);
    my ($t, $r, $length);

    $x1 = 0 unless $x1;
    $x2 = 0 unless $x2;
    $y1 = 0 unless $y1;
    $y2 = 0 unless $y2;
    $z1 = 0 unless $z1;
    $z2 = 0 unless $z2;
    my $dx=$x1-$x2;
    my $dy=$y1-$y2;
    my $dz=$z1-$z2;
    $order = "" unless defined $order;
    $self->Group('line("'.join('", "',@_).'")');
    $self->def("Line-Material")->appearance($appearance);
    if ($dx && $order =~ /x/) {
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x$/i;
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x../i;
	$t = ($x1-($dx/2))." $y2 $z1" if $order =~ /yxz/i;
	$t = ($x1-($dx/2))." $y1 $z2" if $order =~ /zxy/i;
	$t = ($x1-($dx/2))." $y2 $z2" if $order =~ /..x$/i;
	$self->Transform($t,"0 0 1 $::pi_2");
	$self->Shape(sub{$self->Cylinder($radius,abs($dx))},
		sub{$self->use("Line-Material")});
	$self->EndTransform;
    }
    if ($dy && $order =~ /y/) {
	$t = "$x1 ".($y1-($dy/2))." $z1" if $order =~ /^y$/i;
	$t = "$x1 ".($y1-($dy/2))." $z1" if $order =~ /^y../i;
	$t = "$x2 ".($y1-($dy/2))." $z1" if $order =~ /xyz/i;
	$t = "$x1 ".($y1-($dy/2))." $z2" if $order =~ /zyx/i;
	$t = "$x2 ".($y1-($dy/2))." $z2" if $order =~ /..y$/i;
	$self->Transform($t);
	$self->Shape(sub{$self->Cylinder($radius,abs($dy))},
		sub{$self->use("Line-Material")});
	$self->EndTransform;
    }
    if ($dz && $order =~ /z/) {
	$t = "$x1 $y1 ".($z1-($dz/2)) if $order =~ /^z$/i;
	$t = "$x1 $y1 ".($z1-($dz/2)) if $order =~ /^z../i;
	$t = "$x1 $y2 ".($z1-($dz/2)) if $order =~ /yzx/i;
	$t = "$x2 $y1 ".($z1-($dz/2)) if $order =~ /xzy/i;
	$t = "$x2 $y2 ".($z1-($dz/2)) if $order =~ /..z$/i;
	$self->Transform($t,"1 0 0 $::pi_2");
	$self->Shape(sub{$self->Cylinder($radius,abs($dz))},
		sub{$self->use("Line-Material")});
	$self->EndTransform;
    }
    unless ($order) {
	$length = sqrt($dx*$dx + $dy*$dy + $dz*$dz);
	$t = ($x1-($dx/2))." ".($y1-($dy/2))." ".($z1-($dz/2));
	$r = "$dx ".($dy+$length)." $dz $::pi";
	$self->Transform($t,$r);
	$self->Shape(sub{$self->Cylinder($radius,$length)},
		sub{$self->use("Line-Material")});
	$self->EndTransform;
    }
    $self->End("line",TRUE);
    return $self;
}

#--------------------------------------------------------------------

sub box {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Shape(
	sub{$self->Box($width,$height,$depth)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub cone {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Shape(
	sub{$self->Cone($radius, $height)},
    	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub cube {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $height=$width unless defined $height;
    $depth=$width unless defined $depth;
    $self->Shape(
	sub{$self->Box($width,$height,$depth)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub cylinder {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Shape(
	sub{$self->Cylinder($radius, $height)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub sphere {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($radius) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Shape(
	sub{$self->Sphere($radius)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub text {
    my $self = shift;
    my ($string, $appearance, $font) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $string =~ s/"/$quote/g if defined $string;
    $self->appearance($appearance) if $appearance;
    if ($font) {
	$self->Text($string,sub{$self->FontStyle(split(/\s+/,$font))});
    } else {
	$self->Text($string);
    }
    return $self;
}

#--------------------------------------------------------------------

sub cylindersensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->cylindersensor("name")\n}) unless @_;
    my ($name, $enabled) = @_;
    $self->def($name)->CylinderSensor($enabled);
    return $self;
}

sub spheresensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->spheresensor("name")\n}) unless @_;
    my ($name, $enabled) = @_;
    $self->def($name)->SphereSensor($enabled);
    return $self;
}

sub timesensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->timesensor("name")\n}) unless @_;
    my ($name, $cycleInterval, $loop, $enabled) = @_;
    $self->def($name)->TimeSensor($cycleInterval, $loop, $enabled);
    return $self;
}

sub touchsensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->touchsensor("name")\n}) unless @_;
    my ($name, $enabled) = @_;
    $self->def($name)->TouchSensor($enabled)->VRML_trim;
    return $self;
}

#--------------------------------------------------------------------

sub appearance {
    my $self = shift;
    my ($appearance_list) = @_;
    return $self->VRML_put("Appearance {}\n") unless $appearance_list;
    my $texture = "";
    my ($item,$color,$multi_color,$key,$value,$num_color,%material);
    ITEM:
    foreach $item (split(/\s*;\s*/,$appearance_list)) {
	($key,$value) = split(/\s*[=:]\s*/,$item,2);
	unless ($value) {	# color only
	    $value = $key;
	    $key = "diffuseColor";
	}
	MODE: {
	    if ($key =~ /^a/i)  { $key = "ambientIntensity";  last MODE; }
	    if ($key =~ /^d/i)  { $key = "diffuseColor";  last MODE; }
	    if ($key =~ /^e/i)  { $key = "emissiveColor"; last MODE; }
	    if ($key =~ /^sh/i) { $key = "shininess";     last MODE; }
	    if ($key =~ /^s/i)  { $key = "specularColor"; last MODE; }
	    if ($key =~ /^tr/i) { $key = "transparency";  last MODE; }
	    if ($key =~ /^tex/i) { $texture = $value; next ITEM; }
	}
	if ($value =~ /,/) {	# multi color field
	    foreach $color (split(/\s*,\s*/,$value)) {
	    	($num_color,$color) = rgb_color($color);
		$value = $num_color;
	    	$value .= "	# $color" if $color;
	    	push @values, $value;
	    }
	    $material{$key} = $values[0]; # ignore foll. colors
	    $multi_color = 1;	
	} else {
	    ($num_color,$color) = rgb_color($value);
	    $value = $num_color;
	    $value .= "	# $color" if $color;
	    $material{$key} = $value;
	}
    }
    $self->Appearance(
	%material ? sub{$self->Material(%material)} : undef,
	$texture =~ /\.gif|\.jpg|\.bmp/i ? sub{$self->ImageTexture(split(/\s+/,$texture))} : undef || 
	$texture =~ /\.avi|\.mpg|\.mov/i ? sub{$self->MovieTexture(split(/\s+/,$texture))} : undef 
    );
    return $self;
}


#--------------------------------------------------------------------

sub lod_begin {
    my $self = shift;
    my ($range, $center) = @_;
    $self->LOD($range,$center);
    return $self;
}

sub lod_end {
    my $self = shift;
    $self->End($_[0],TRUE); #  close [ and {
    return $self;
}

#--------------------------------------------------------------------

sub def {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->def("name",sub{code});\n}) unless @_;
    my ($name, $code) = @_;
    $self->DEF($name);
    if (defined $code) {
	if (ref($code) eq "CODE") {
	    $self->{'TAB'} .= "\t";
	    my $pos = $#{$self->{'VRML'}}+1;
	    &$code;
	    $self->VRML_trim($pos);
	    chop($self->{'TAB'});
	} else {
	    $self->VRML_put($code);
	}
    }
    return $self;
}

sub use {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->use("name")\n}) unless @_;
    my ($name) = @_;
    $self->USE($name);
    return $self;
}

sub sound {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->sound("url", "description", ...)\n}) unless @_;
    my ($url, $description, $location, $direction, $intensity, $loop, $pitch) = @_;
    $loop = defined $loop && $loop ? "TRUE" : "FALSE";
    $self->Sound(sub{$self->DEF($description)->AudioClip($url, $description, $loop, $pitch)->VRML_trim},
	$location, $direction, $intensity, 100 );
    return $self;
}

1;

__END__

=head1 NAME

VRML::VRML2.pm - implements VRML methods with the VRML 1.x standard

=head1 SYNOPSIS

    use VRML::VRML2;

=head1 DESCRIPTION

Following methods are currently implemented. 

=over 4

=item *
begin('transformation');
C<  . . . >

=item *
end(['comment']);

=item *
backgroundcolor('groundcolor','skycolor');

=item *
backgroundimage('backUrl','bottomUrl');

=item *
title('string');

=item *
info('string');

=item *
cameras_begin('whichCameraNumber');

=item *
camera_set('positionXYZ','orientationXYZ',fieldOfView); // persp. cameras

=item *
camera('positionXYZ','orientationXYZ',fieldOfView); // persp. camera

=item *
anchor_begin('Url','description','parameter');

=item *
box('width [height [depth]]','appearance');

=item *
cone('radius height','appearance');

=item *
cube('width','appearance');

=item *
cylinder('radius [height]','appearance');

=item *
line('fromXYZ','toXYZ',radius,'appearance','[x][y][z]');

=item *
sphere('radius_x [radius_y radius_z]','appearance');

=item *
text('string','appearance','size style family');

=item *
transform('type=value ; ...');

I<Where type can be:>

	t = translation
	r = rotation
	c = center
	o = scaleOrientation
	f = scaleFactor

=item *
appearance('type=value1,value2 ; ...');

I<Where type can be:>

	a = ambientColor
	d = diffuseColor
	e = emissiveColor
	s = specularColor
	sh = shininess
	tr = transparency
	tex = texture filename[,wrapS[,wrapT]]

I<and color values see>

VRML::Color


=back

=head1 SEE ALSO

VRML

VRML::VRML2::Standard

VRML::Basic

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut

