package VRML::VRML1;
use strict "refs";

require 5.000;
use VRML::Color;
require VRML::VRML1::Standard;
@ISA = qw(VRML::VRML1::Standard);

$VERSION="0.85";
$pi = 3.1415926;
$pi_2 = $pi/2;

#--------------------------------------------------------------------

sub VERSION {
    my $self = shift;
    return $VERSION, $self;
}

sub new {
    my $class = shift;
    my $version = shift;
    my $self = new VRML::VRML1::Standard;
    my $this = bless $self;
    $self->{'browser'} = "";
    $self->{'def'} = {};
    $self->{'use_background'} = 0;
    $self->{'content_type'} = "x-world/x-vrml";
    $this->VRML_init("#VRML V1.0 ascii\n\n");
    $self->{'version'} = 0;
    $this->version($version) if defined $version;
    return bless $self, $class;
}

sub version {
    my $self = shift;
    my $vrml_version = shift;
    my $vrml;
    if (defined $vrml_version) {
	if ($vrml_version =~ /1.1/) {
	    $self->{'version'} = 1.1;
	    $vrml = "#VRML V1.1 utf8\n\n";
	} else {
	    $self->{'version'} = 1;
	    $vrml = "#VRML V1.0 ascii\n\n";
	}
    } else {
	$self->{'version'} = 0;
	$vrml = "#VRML V1.0 ascii\n\n";
    }
    $self->VRML_init($vrml);
    return $self if $self->{'SELF'};
    return $vrml;
}

sub display {
    my $self = shift;
    my @keys = @_ ? @_ : sort keys %$self;
    my $key;
    foreach $key (@keys) {
	unless (defined $self->{$key}) {
	    print "# $key => undef";
	    next;
	}
	print "# $key => $self->{$key}";
	print " [".(join(', ',@{$self->{$key}}))."]" if defined ref($self->{$key}) && ref($self->{$key}) eq "ARRAY" && $key ne 'VRML';
	print "\n";
    }
    return $self;
}

sub browser {
    my $self = shift;
    ($self->{'browser'}) = @_ if @_;
    $self->{'use_background'} = $self->{'browser'} =~ /Live3d|WebFx|Webspace/i;
    $self->VRML_put("# Set Browser to: '$self->{'browser'}'\n");
    return $self;
}

sub print {
    my $self = shift;
    $self->VRML_print;
}
#--------------------------------------------------------------------
#   VRML Group Methods
#--------------------------------------------------------------------
sub begin {
    my $self = shift;
    $self->Separator(@_);
    return $self;
}

sub end {
    my $self = shift;
    $self->End(@_);
    return $self;
}

#--------------------------------------------------------------------
#   VRML Methods
#--------------------------------------------------------------------

sub backgroundimage {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->backgroundimage("URL");\n}) unless @_;
    return $self unless $self->{'use_background'};
    my ($url) = @_;
    $self->def("BackgroundImage")->Info($url)->VRML_trim;
    return $self;
}

sub backgroundcolor {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->backgroundcolor("color");\n}) unless @_;
    return $self unless $self->{'use_background'};
    my ($colorstring) = @_;
    my $num_color;
    ($num_color,$colorstring) = vrml_color($colorstring);
    $self->def("BackgroundColor")->Info($num_color,$colorstring)->VRML_trim;
    return $self;
}

sub info {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->info("string");\n}) unless @_;
    $self->Info(@_);
    return $self;
}

#--------------------------------------------------------------------

sub cameras_begin {
    my $self = shift;
    my ($whichChild) = @_;
    return $self->VRML_put(qq{\n# CALL: ->cameras_begin("whichCameraNumber");\n}) if defined $self->{'HELP'};
    $whichChild = (defined $whichChild && $whichChild > 0) ? $whichChild-1 : 0;
    $self->def("Cameras")->Switch($whichChild)->VRML_trim;
    return $self;
}

sub auto_camera_set {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->auto_camera_set()\n}) if defined $self->{'HELP'};
    if (defined $self->{'camera'}) {
	my $x = ($self->{'Xmax'}+$self->{'Xmin'})/2;
	my $y = ($self->{'Ymax'}+$self->{'Ymin'})/2;
	my $z = ($self->{'Zmax'}+$self->{'Zmin'})/2;
	my $dx = abs($self->{'Xmax'}-$x); # todo calc angle
	my $dy = abs($self->{'Ymax'}-$y);
	my $dz = abs($self->{'Zmax'}-$z);
	my $dist = 0;
	$dist = $dx if $dx > $dist;
	$dist = $dy if $dy > $dist;
	$dist = $dz if $dz > $dist;
	my $camera = $self->{'camera'};
	my $offset = $#{$self->{'VRML'}}+1;
	($self->{'TAB'}) = $self->{'VRML'}[$camera] =~ /(\t*)/;
	$self->camera_set("$x $y $z",$dist,60);
	@_ = splice(@{$self->{'VRML'}}, $offset);
	splice(@{$self->{'VRML'}}, $camera, $#_+1, @_);
    } else {
	$self->camera_set(@_);
    }
    return $self;
}

sub camera_set {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->camera_set("centerXYZ","distanceXYZ",heightAngle); /* persp. cameras */\n}) if defined $self->{'HELP'};
    my ($center, $distance, $heightAngle) = @_;
    $self->{'camera'} = $#{$self->{'VRML'}}+1 unless defined $self->{'camera'};
    my ($x, $y, $z) = split(/\s+/,$center);
    my ($dx, $dy, $dz) = defined $distance ? split(/\s+/,$distance) : (0,0,0);
    $heightAngle = 90 unless defined $heightAngle;
    $x = 0 unless defined $x;
    $y = 0 unless defined $y;
    $z = 0 unless defined $z;
    $dx = 1 unless defined $dx;
    $dy = $dx unless defined $dy;
    $dz = $dx unless defined $dz;
    $self->camera("Front", "$x $y ".($z+$dz), "0 0 1", 0,$heightAngle);
    $self->camera("Top", "$x ".($y+$dy)." $z", "1 0 0",-90,$heightAngle);
    $self->camera("Right", ($x+$dx)." $y $z", "0 1 0", 90,$heightAngle);
    $self->camera("Back", "$x $y ".($z-$dz), "0 1 0",180,$heightAngle);
    $self->camera("Left", ($x-$dx)." $y $z", "0 1 0",-90,$heightAngle);
    $self->camera("Bottom", "$x ".($y-$dy)." $z", "1 0 0", 90,$heightAngle);
    return $self;
}
sub camera {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->camera("name", "positionXYZ", "orientationXYZ", degree, heightAngle, focalDistance, nearDistance, farDistance)\n}) if defined $self->{'HELP'};
    my ($name,
	$position, $orientation, $degree, $heightAngle, 
	$focalDistance, $nearDistance, $farDistance) = @_;
    $orientation = "0 0 1" unless defined $orientation;
    $degree = 0 unless defined $degree;
    $degree *= $pi/180 if (abs($degree) > 2*$pi);
    $heightAngle = 0 unless defined $heightAngle;
    $heightAngle *= $pi/180 if (abs($heightAngle) > 2*$pi);
    undef $nearDistance if $self->{'version'} < 1.1;
    undef $farDistance if $self->{'version'} < 1.1;
    $self->def($name)->PerspectiveCamera($position, $orientation." ".$degree, $heightAngle, $focalDistance, $nearDistance, $farDistance)->VRML_trim;
    return $self;
}

sub ocamera_set {
    my $self = shift;
    my ($center, $distance, $height) = @_;
    $center = "" unless defined $center;
    $distance = "" unless defined $distance;
    my ($x, $y, $z) = split(/\s+/,$center);
    my ($dx, $dy, $dz) = split(/\s+/,$distance);

    $x = 1 unless defined $x;
    $y = $x unless defined $y;
    $z = $x unless defined $z;
    $dx = 0 unless defined $dx;
    $dy = 0 unless defined $dy;
    $dz = 0 unless defined $dz;
    $self->ocamera("Front",  "$dx $dy $z", "0 0 1",  0,$height);
    $self->ocamera("Top",   "$dx $y $dz", "1 0 0",-90,$height);
    $self->ocamera("Right", "$x $dy $dz", "0 1 0", 90,$height);
    $self->ocamera("Left",  "-$x $dy $dz","0 1 0",-90,$height);
    $self->ocamera("Bottom","$dx -$y $dz","1 0 0", 90,$height);
    $self->ocamera("Back",  "$dx $dy -$z","0 1 0",180,$height);
    return $self;
}
sub ocamera {
    my $self = shift;
    my ($name,
	$position, $orientation, $degree, $height, 
	$focalDistance, $nearDistance, $farDistance) = @_;
    $orientation = "" unless defined $orientation;
    if ($degree) {
    	$degree *= $pi/180 if (abs($degree) > 2*$pi);
    } else {
	$degree = 0;
    }
    undef $nearDistance if $self->{'version'} < 1.1;
    undef $farDistance if $self->{'version'} < 1.1;
    $self->def($name)->OrthographicCamera($position, $orientation." ".$degree, $height, $focalDistance, $nearDistance, $farDistance)->VRML_trim;
    return $self;
}

sub light {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->light(intensity, direction, color)\n}) unless @_;
    my ($direction, $intensity, $color, $ambientIntensity, $on) = @_;
    $intensity /= 100 if $intensity > 1;
    $self->DirectionalLight($direction, $intensity, $color, $ambientIntensity, $on);
    return $self;
}

#--------------------------------------------------------------------

sub anchor_begin {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->anchor_begin("URL","description","parameter");\n}) unless @_;
    my ($url, $description, $parameter) = @_;
    undef $parameter if $self->{'browser'} !~ /Live3D/i;
    $self->WWWAnchor($url, $description, $parameter);
    return $self;
}

sub spin_begin {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->spin_begin("axisXYZ","degree"); /* Live3D only */\n}) unless @_;
    my ($axis, $degree) = @_;
    $degree *= $pi/180 if abs($degree) > 2*$pi;
    $self->SpinGroup($axis, $degree);
    return $self;
}

#--------------------------------------------------------------------

sub line {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->line("fromXYZ","toXYZ",radius,"material","[x][y][z]");\n}) unless @_;
    my ($from,$to,$radius,$material,$order) = @_;
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
    $self->Separator('line("'.join('", "',@_).'")');
    $self->material($material);
    if ($dx && $order =~ /x/) {
	$self->Separator("line_x");
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x$/i;
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x../i;
	$t = ($x1-($dx/2))." $y2 $z1" if $order =~ /yxz/i;
	$t = ($x1-($dx/2))." $y1 $z2" if $order =~ /zxy/i;
	$t = ($x1-($dx/2))." $y2 $z2" if $order =~ /..x$/i;
	$self->Transform($t,"0 0 1 $pi_2");
	$self->Cylinder($radius,abs($dx));
	$self->End();
    }
    if ($dy && $order =~ /y/) {
	$self->Separator("line_y");
	$t = "$x1 ".($y1-($dy/2))." $z1" if $order =~ /^y$/i;
	$t = "$x1 ".($y1-($dy/2))." $z1" if $order =~ /^y../i;
	$t = "$x2 ".($y1-($dy/2))." $z1" if $order =~ /xyz/i;
	$t = "$x1 ".($y1-($dy/2))." $z2" if $order =~ /zyx/i;
	$t = "$x2 ".($y1-($dy/2))." $z2" if $order =~ /..y$/i;
	$self->Transform($t);
	$self->Cylinder($radius,abs($dy));
	$self->End();
    }
    if ($dz && $order =~ /z/) {
	$self->Separator("line_z");
	$t = "$x1 $y1 ".($z1-($dz/2)) if $order =~ /^z$/i;
	$t = "$x1 $y1 ".($z1-($dz/2)) if $order =~ /^z../i;
	$t = "$x1 $y2 ".($z1-($dz/2)) if $order =~ /yzx/i;
	$t = "$x2 $y1 ".($z1-($dz/2)) if $order =~ /xzy/i;
	$t = "$x2 $y2 ".($z1-($dz/2)) if $order =~ /..z$/i;
	$self->Transform($t,"1 0 0 $pi_2");
	$self->Cylinder($radius,abs($dz));
	$self->End();
    }
    unless ($order) {
	$length = sqrt($dx*$dx + $dy*$dy + $dz*$dz);
	$t = ($x1-($dx/2))." ".($y1-($dy/2))." ".($z1-($dz/2));
	$r = "$dx ".($dy+$length)." $dz $pi";
	$self->Transform($t,$r);
	$self->Cylinder($radius,$length);
    }
    $self->End("line");
    return $self;
}

#--------------------------------------------------------------------

sub coordinate_system {
    my $self = shift;
    my ($length,$radius) = @_;
    $radius = 0.4 unless $radius;
    $length = 10 unless $length;
    $cone_radius = 3 * $radius;
    $height = 3 * $cone_radius;
    $self->Separator("Coordinate System");
    $self->material("green");
    $self->cylinder("$radius $length","0 ".$length/2);
    $self->cone("$cone_radius $height","0 $length 0");
    $self->Rotation("1 0 0 $pi_2");
    $self->material("blue");
    $self->cylinder("$radius $length","0 ".$length/2);
    $self->cone("$cone_radius $height","0 $length 0");
    $self->Rotation("0 0 1 -$pi_2");
    $self->material("red");
    $self->cylinder("$radius $length","0 ".$length/2);
    $self->cone("$cone_radius $height","0 $length 0");
    $self->End();
    return $self;
}

#--------------------------------------------------------------------

sub text {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->text("string","transformation","material","size style family");\n}) unless @_;
    my ($string, $transform, $material, $font) = @_;
    $self->Separator("text") if $transform or $material or $font;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->FontStyle(split(/\s+/,$font)) if $font;
    $self->AsciiText($string);
    $self->End("text") if $transform or $material or $font;
    return $self;
}

#--------------------------------------------------------------------

sub textcube {
    my $self = shift;
    my ($dimension, $transform, $material, $string, $textmaterial, $font, $font_dist, $unvisible, $no_top) = @_;
    my ($width, $height, $depth) = split(/\s+/,$dimension);
    $font = "" unless defined $font;
    $font_dist = 0.1 if !defined $font_dist || $font_dist <= 0;

    $height = 1 unless $height;
    $depth = $width unless $depth;
    $self->Separator('textcube("'.join('", "',@_).'")');
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->lod_begin($height*$unvisible)->Separator("detailed version") if defined $unvisible;
    $self->def("PureCube")->Cube($width, $height, $depth)->VRML_trim;
	if ($textmaterial) {
	    $self->material($textmaterial);
	} else {
	    $self->material("black");
	}
	$self->FontStyle(($height*0.8),split(/\s+/,$font));
	$self->Separator("Front text")
	     ->Transform("0 ".-($height/4)." ".($depth/2 + $font_dist))
	     ->AsciiText($string, 0, "CENTER")
	     ->End();
	$self->Separator("Top text")
	     ->Transform("0 ".($height/2 + $font_dist)." ".($depth/2 - $height/4), "1 0 0 -$pi_2")
#	     ->AsciiText($string, $width/1.5, "CENTER")
	     ->AsciiText($string, 0, "CENTER")
	     ->End unless $no_top;
    $self->use("PureCube")->End if defined $unvisible;
    $self->End("textcube");
    return $self;
}

#--------------------------------------------------------------------

sub cube {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->cube("width [height [depth]]","transformation","material");\n}) unless @_;
    my ($dimension, $transform, $material) = @_;
    my ($width,$height,$depth);
    $self->Separator("cube") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $height=$width unless defined $height;
    $depth=$width unless defined $depth;
    $self->Cube($width,$height,$depth);
    $self->End("cube") if $transform or $material;
    return $self;
}

sub cylinder {
    my $self = shift;
    my ($dimension, $transform, $material) = @_;
    return $self->VRML_put(qq{\n# CALL: ->cylinder("radius height","transformation","material");\n}) unless @_;
    $self->Separator("cylinder") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Cylinder($radius, $height);
    $self->End("cylinder") if $transform or $material;
    return $self;
}

sub pipe {
    my $self = shift;
    my ($dimension, $transform, $material) = @_;
    return $self->VRML_put(qq{\n# CALL: ->pipe("radius length","transformation","material");\n}) unless @_;
    $self->Separator("pipe") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension,2);
    $self->Cylinder($radius, $height,"SIDES");
    $self->End("pipe") if $transform or $material;
    return $self;
}

sub tube {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->tube("radius height","transformation","material");\n}) unless @_;
    my ($dimension, $transform, $material) = @_;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension,2);
    $self->Separator("tube") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->Cylinder(split(/\s+/,$dimension,2),"BOTTOM","SIDES");
    $self->End("tube") if $transform or $material;
    return $self;
}

sub disk {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->disk("radius","transformation","material");\n}) unless @_;
    my ($dimension, $transform, $material) = @_;
    my ($radius) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Separator("disk") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->Cylinder($radius, 0,"BOTTOM");
    $self->End("disk") if $transform or $material;
    return $self;
}

sub cone {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->cone("radius height","transformation","material");\n}) unless @_;
    my ($dimension, $transform, $material) = @_;
    ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Separator("cone") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->Cone($radius, $height);
    $self->End("cone") if $transform or $material;
    return $self;
}

sub sphere {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->sphere("radius_x [radius_y radius_z]","transformation","material");\n}) unless @_;
    my ($dimension, $transform, $material) = @_;
    my ($x,$y,$z);
    $self->Separator("sphere");
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    ($x, $y, $z) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    if ($y) {
	$self->Scale("$x $y $z");
	$self->Sphere(1);
    } else {
	$self->Sphere($x);
    }
    $self->End("sphere");
    return $self;
}

#--------------------------------------------------------------------

sub material {
    my $self = shift;
    my $vrml = "";
    unless (@_) {
	$vrml .= qq{\n# CALL: ->material("type=value1,value2 ; ...");\n};
	$vrml .= "#\n";
	$vrml .= "#  Where type can be: \n";
	$vrml .= "#\n";
	$vrml .= "#	a	ambientColor\n";
	$vrml .= "#	d	diffuseColor\n";
	$vrml .= "#	e	emissiveColor\n";
	$vrml .= "#	s	specularColor\n";
	$vrml .= "#	sh	shininess\n";
	$vrml .= "#	tr	transparency\n";
	$vrml .= "#	tex	texture filename[,wrapS[,wrapT]]\n";
	$vrml .= "#\n";
	$vrml .= "#  And values like 'red' for color or '50%' for shininess.\n";
	$vrml .= "#\n";
	$vrml .= "#  Other examples of colors are:\n";
	($value,$color) = vrml_color("green");
	$vrml .= "#	green = \"$value\" # $color\n";
	($value,$color) = vrml_color("yellow%30");
	$vrml .= "#	yellow%30 = \"$value\" # $color\n";
	($value,$color) = vrml_color("gray%30");
	$vrml .= "#	gray%30 = \"$value\" # $color It's the white saturation !\n";
	$self->VRML_put($vrml);
	return $self;
    }
    my ($material_list) = @_;
    my ($item,$color,$multi_color,$key,$value,$num_color,$texture,%material);
    ITEM:
    foreach $item (split(/\s*;\s*/,$material_list)) {
	($key,$value) = split(/\s*[=:]\s*/,$item,2);
	unless ($value) {	# color only
	    $value = $key;
	    $key = "diffuseColor";
	}
	MODE: {
	    if ($key =~ /^a/i)  { $key = "ambientColor";  last MODE; }
	    if ($key =~ /^d/i)  { $key = "diffuseColor";  last MODE; }
	    if ($key =~ /^e/i)  { $key = "emissiveColor"; last MODE; }
	    if ($key =~ /^sh/i) { $key = "shininess";     last MODE; }
	    if ($key =~ /^s/i)  { $key = "specularColor"; last MODE; }
	    if ($key =~ /^tr/i) { $key = "transparency";  last MODE; }
	    if ($key =~ /^tex/i) { $texture = $value; next ITEM; }
	}
	if ($value =~ /,/) {	# multi color field
	    foreach $color (split(/\s*,\s*/,$value)) {
	    	($num_color,$color) = vrml_color($color);
		$value = "$num_color,";
	    	$value .= "	# $color" if $color;
	    	push @values, $value;
	    }
	    $material{$key} = [@values];
	    $multi_color = 1;	
	} else {
	    ($num_color,$color) = vrml_color($value);
	    $value = $num_color;
	    $value .= "	# $color" if $color;
	    $material{$key} = $value;
	}
    }
    $self->Material(%material);
    $self->MaterialBinding("PER_PART") if $multi_color;
    $self->Texture2(split(/\s+/,$texture)) if $texture;
    return $self;
}


#--------------------------------------------------------------------

sub transform {
    my $self = shift;
    my $vrml = "";
    unless (@_) {
	$vrml = qq{\n# CALL: ->transform("type=value ; ...");\n};
	$vrml .= "#\n";
	$vrml .= "#  Where type can be: \n";
	$vrml .= "#\n";
	$vrml .= "#	t	translation\n";
	$vrml .= "#	r	rotation\n";
	$vrml .= "#	c	center\n";
	$vrml .= "#	f	scaleFactor\n";
	$vrml .= "#	o	scaleOrientation\n";
	$self->VRML_put($vrml);
	return $self;
    }
    my ($transform_list) = @_;
    @transform = ref($transform_list) ? @$transform_list : split(/\s*;\s*/,$transform_list);
    my ($item, $key, $value);
    my ($x,$y,$z,$rad,$t,$r,$f,$o,$c);
    foreach $item (@transform) {
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
	    $rad *= $pi/180 if abs($rad) > 2*$pi;
	    $r = "$x $y $z $rad";
	}
    }
    $self->Transform($t,$r,$f,$o,$c);
    return $self;
}

sub lod_begin {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->lod_begin("range"[,"center"]);\n}) unless @_;
    my ($range, $center) = @_;
    $self->LOD($range,$center);
    return $self;
}

#--------------------------------------------------------------------

sub def {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->def("name");\n}) unless @_;
    my ($name) = @_;
    $self->{'def'}{$name} = $#{$self->{'VRML'}}+1;
    $self->DEF($name);
    return $self;
}

sub def_vrml {
    my $self = shift;
    return $self->VRML_put(qq{\n# CALL: ->def_vrml("name","VRML code");\n}) unless @_;
    my ($name, $code) = @_;
    $self->{'def'}{$name} = $#{$self->{'VRML'}}+1;
    $self->DEF($name)->VRML_put($code)->VRML_trim;
    return $self;
}

sub use {
    my $self = shift;
    my ($name, $transform, $material) = @_;
    $self->Separator("$name") if $transform or $material;
    $self->transform($transform) if $transform;
    $self->material($material) if $material;
    $self->USE($name);
    $self->End() if $transform or $material;
    return $self;
}

#--------------------------------------------------------------------
# Short descriptions of the extended VRML methods
#--------------------------------------------------------------------
sub help {
    my $self = shift;
    my ($pattern) = $_[0] ? @_ : "";
    $self->{'HELP'} = 1;
    $self->VRML_put(qq{VRML::VRML1.pm - Version $VERSION\n});
    $self->VRML_put(qq{\n# CALL: ->begin(["comment"]);\n}) if "begin end" =~ /$pattern/i;
    $self->VRML_add(qq{#         . . .\n#       end(["comment"]);\n}) if "begin end" =~ /$pattern/i;
    $self->backgroundcolor() if "backgroundcolor" =~ /$pattern/i;
    $self->backgroundimage() if "backgroundimage" =~ /$pattern/i;
    $self->cameras_begin() if "cameras_begin" =~ /$pattern/i;
    $self->camera_set() if "camera_set" =~ /$pattern/i;
    $self->camera() if "camera" =~ /$pattern/i;
    $self->anchor_begin() if "anchor_begin" =~ /$pattern/i;
    $self->spin_begin() if "spin_begin" =~ /$pattern/i;
    $self->light() if "light" =~ /$pattern/i;
    $self->info() if "info" =~ /$pattern/i;
    $self->text() if "text" =~ /$pattern/i;
    $self->cube() if "cube" =~ /$pattern/i;
    $self->cylinder() if "cylinder" =~ /$pattern/i;
    $self->pipe() if "pipe" =~ /$pattern/i;
    $self->tube() if "tube" =~ /$pattern/i;
    $self->disk() if "disk" =~ /$pattern/i;
    $self->cone() if "cone" =~ /$pattern/i;
    $self->sphere() if "sphere" =~ /$pattern/i;
    $self->line() if "line" =~ /$pattern/i;
    $self->transform() if "transform" =~ /$pattern/i;
    $self->material() if "material" =~ /$pattern/i;
    return $self;
}

1;

__END__

=head1 NAME

VRML::VRML1.pm - implements VRML methods with the VRML 1.x standard

=head1 SYNOPSIS

    use VRML::VRML1;

=head1 DESCRIPTION

Following functions are currently implemented. 

=over 4

=item *
begin(['comment']);
C<  . . . >

=item *
end(['comment']);

=item *
backgroundcolor('color');

=item *
backgroundimage('URL');

=item *
info('string');

=item *
cameras_begin('whichCameraNumber');

=item *
camera_set('positionXYZ','orientationXYZ',heightAngle); // persp. cameras

=item *
camera('positionXYZ','orientationXYZ',heightAngle); // persp. camera

=item *
anchor_begin('URL','description','parameter');

=item *
spin_begin('axisXYZ','degree'); // Live3D only

=item *
text('string','transformation','material','size style family');

=item *
cube('width [height [depth]]','transformation','material');

=item *
cylinder('radius [height]','transformation','material');

=item *
tube('radius height','transformation','material');

=item *
disk(radius,'transformation','material');

=item *
cone('radius height','transformation','material');

=item *
sphere('radius_x [radius_y radius_z]','transformation','material');

=item *
line('fromXYZ','toXYZ',radius,'material','[x][y][z]');

=item *
transform('type=value ; ...');

I<Where type can be:>

	t = translation
	r = rotation
	c = center
	o = scaleOrientation
	f = scaleFactor

=item *
material('type=value1,value2 ; ...');

I<Where type can be:>

	a = ambientColor
	d = diffuseColor
	e = emissiveColor
	s = specularColor
	sh = shininess
	tr = transparency
	tex = texture filename[,wrapS[,wrapT]]

I<and color values see VRML::Color>


=back

=cut

