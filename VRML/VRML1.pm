package VRML::VRML1;
use strict "refs";

require 5.000;
use VRML::Color;
require VRML::VRML1::Standard;
@ISA = qw(VRML::VRML1::Standard);

# $VERSION="0.97";
%supported = ( 'quote' => "Live3D|WorldView",
	      'navinfo' => "Live3D",		# not WorldView & CosmoPlayer
	      'gzip'   => "Live3D|WorldView|Cosmo|VRweb",
	      'target' => "Live3D|WorldView",
	      'frames' => "Netscape|Mozilla|Internet Explorer|MSIE"
);

#--------------------------------------------------------------------

sub new {
    my $class = shift;
    my $version = shift;
    my $self = new VRML::VRML1::Standard;
    $self->{'browser'} = "";
    $self->{'content_type'} = "x-world/x-vrml";
    $self->{'version'} = 1;
    $self->VRML_head("#VRML V1.0 ascii");
    return bless $self, $class;
}

sub browser {
    my $self = shift;
    ($self->{'browser'}) = @_ if @_;
    $self->VRML_put("# Set Browser to: '$self->{'browser'}'\n");
    return $self;
}

sub supported {
    my $self = shift;
    my $feature = shift;
    return $self->{'browser'} =~ /$supported{$feature}/i;
}

#--------------------------------------------------------------------
#   VRML Grouping Methods
#--------------------------------------------------------------------
sub at {
    my $self = shift;
    $self->transform_begin(@_);
    return $self;
}

sub back {
    my $self = shift;
    $self->transform_end();
    return $self;
}

sub begin {
    my $self = shift;
    $self->Group($_[0]);
    return $self;
}

sub end {
    my $self = shift;
    $self->End($_[0]);
    return $self;
}

sub group_begin {
    my $self = shift;
    $self->Group(@_);
    return $self;
}

sub group_end {
    my $self = shift;
    $self->End($_[0]);
    return $self;
}

sub collision_begin {
    my $self = shift;
    $self->VRML_row("CollideStyle { collide TRUE }\n");
    return $self;
}

sub collision_end {
    return shift;
}

sub anchor_begin {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->anchor_begin("URL","description","target=parameter");\n}) unless @_;
    my ($url, $description, $parameter) = @_;
    my $target = undef;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $description =~ s/"/$quote/g if defined $description;
    if (defined $parameter && $self->{'browser'} =~ /$supported{'target'}/i) {
	($target = $1) =~ s/"/$quote/g if ($parameter =~ /target\s*=(.+)/i);
    }
    $self->WWWAnchor($url, $description, $target);
    return $self;
}

sub anchor_end {
    my $self = shift;
    $self->End($_[0]);
    return $self;
}

sub lod_begin {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->lod_begin("range"[,"center"]);\n}) unless @_;
    my ($range, $center) = @_;
    $self->LOD($range,$center);
    return $self;
}

sub lod_end {
    my $self = shift;
    $self->End($_[0]);
    return $self;
}

sub inline {
    my $self = shift;
    $self->WWWInline(@_);
    return $self;
}

#--------------------------------------------------------------------
#   VRML Methods
#--------------------------------------------------------------------

sub background {
    my $self = shift;
    return $self unless @_;
    my ($color, $image) = @_;
    $self->def("BackgroundColor")->Info(rgb_color($color))->VRML_trim if $color;
    $self->def("BackgroundImage")->Info($image)->VRML_trim if $image;
    return $self;
}

sub backgroundcolor {
    my $self = shift;
    return $self unless @_;
    $self->def("BackgroundColor")->Info(rgb_color(@_))->VRML_trim;
    return $self;
}

sub backgroundimage {
    my $self = shift;
    return $self unless @_;
    $self->def("BackgroundImage")->Info(@_)->VRML_trim;
    return $self;
}

sub title {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->title("string");\n}) unless @_;
    my $title = shift;
    $self->def("Title")->Info($title)->VRML_trim;
    return $self;
}

sub info {
    my $self = shift;
    my $string = shift;
    return $self->VRML_put(qq{# CALL: ->info("string");\n}) unless @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $string =~ s/"/$quote/g if defined $string;
    $self->Info($string);
    return $self;
}

sub headlight {
    my $self = shift;
    return $self unless $self->{'browser'} =~ /$supported{'navinfo'}/i;
    my ($headlight) = @_;
    $headlight = defined $headlight && (!$headlight || $headlight =~ /off|false/i) ? "FALSE" : "TRUE";
    $self->NavigationInfo($headlight);
    return $self;
}
#--------------------------------------------------------------------

sub cameras_begin {
    my $self = shift;
    my ($whichChild) = @_;
    $whichChild = (defined $whichChild && $whichChild > 0) ? $whichChild-1 : 0;
    my $vrml = $self->{'TAB'}."DEF Cameras Switch {\n";
    $vrml .= $self->{'TAB'}."	whichChild $whichChild\n";
    $self->{'TAB_VIEW'} = $self->{'TAB'}."\t";
    $self->{'cameras_begin'} = $#{$self->{'VRML'}}+1 unless defined $self->{'cameras_begin'};
    push @{$self->{'VIEW'}}, $vrml;
    return $self;
}

sub cameras_end {
    my $self = shift;
    chop($self->{'TAB_VIEW'});
    push @{$self->{'VIEW'}}, $self->{'TAB_VIEW'}."}\n";
    splice(@{$self->{'VRML'}}, $self->{'cameras_begin'}, 0, @{$self->{'VIEW'}});
    $self->{'VIEW'} = [];
    return $self;
}

sub camera_auto_set {
    my $self = shift;
    my $factor = shift;
    $factor = 1 unless defined $factor;
    if (defined $self->{'camera_set'}) {
	my $x = ($self->{'Xmax'}+$self->{'Xmin'})/2;
	my $y = ($self->{'Ymax'}+$self->{'Ymin'})/2;
	my $z = ($self->{'Zmax'}+$self->{'Zmin'})/2;
	my $dx = abs($self->{'Xmax'}-$x); # todo: calculate angle
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
    my ($name, $position, $orientation, $heightAngle) = @_;
    my ($x,$y,$z,$degree) = ref($orientation) ? @$orientation : split(/\s+/,$orientation);
    if (defined $degree) {
	$degree *= $::pi/180 if (abs($degree) > 2*$::pi);
	$orientation = "$x $y $z $degree";
    }
    $heightAngle *= $::pi/180 if defined $heightAngle && (abs($heightAngle) > 2*$::pi);
    push @{$self->{'VIEW'}}, $self->{'TAB_VIEW'}."DEF \"$name\" ";
    $self->PerspectiveCamera($position, $orientation, $heightAngle);
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

sub line {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->line("fromXYZ","toXYZ",radius,"appearance","[x][y][z]");\n}) unless @_;
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
    $self->Separator('line("'.join('", "',@_).'")');
    $self->appearance($appearance) if $appearance;
    if ($dx && $order =~ /x/) {
	$self->Separator("line_x");
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x$/i;
	$t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x../i;
	$t = ($x1-($dx/2))." $y2 $z1" if $order =~ /yxz/i;
	$t = ($x1-($dx/2))." $y1 $z2" if $order =~ /zxy/i;
	$t = ($x1-($dx/2))." $y2 $z2" if $order =~ /..x$/i;
	$self->Transform($t,"0 0 1 $::pi_2");
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
	$self->Transform($t,"1 0 0 $::pi_2");
	$self->Cylinder($radius,abs($dz));
	$self->End();
    }
    unless ($order) {
	$length = sqrt($dx*$dx + $dy*$dy + $dz*$dz);
	$t = ($x1-($dx/2))." ".($y1-($dy/2))." ".($z1-($dz/2));
	$r = "$dx ".($dy+$length)." $dz $::pi";
	$self->Transform($t,$r);
	$self->Cylinder($radius,$length);
    }
    $self->End("line");
    return $self;
}

#--------------------------------------------------------------------

sub box {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Group->appearance($appearance) if $appearance;
    $self->Cube($width,$height,$depth);
    $self->End if $appearance;
    return $self;
}

sub cone {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Group->appearance($appearance) if $appearance;
    $self->Cone($radius, $height);
    $self->End if $appearance;
    return $self;
}

sub cube {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $height=$width unless defined $height;
    $depth=$width unless defined $depth;
    $self->Group->appearance($appearance) if $appearance;
    $self->Cube($width,$height,$depth);
    $self->End if $appearance;
    return $self;
}

sub cylinder {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Group->appearance($appearance) if $appearance;
    $self->Cylinder($radius, $height);
    $self->End if $appearance;
    return $self;
}

sub sphere {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($x,$y,$z) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Group->appearance($appearance) if $appearance;
    $self->Sphere($x);
    $self->End if $appearance;
    return $self;
}

sub text {
    my $self = shift;
    my ($string, $appearance, $font, $align) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $string =~ s/"/$quote/g if defined $string;
    $self->Group->appearance($appearance) if $appearance || $font;
    if (defined $font) {
	my ($size, $style, $family) = split(/\s+/,$font,3);
        $self->FontStyle($size, $style, $family);
    }
    if (defined $align) {
	$align =~ s/BEGIN/LEFT/i;
	$align =~ s/MIDDLE/CENTER/i;
	$align =~ s/END/RIGHT/i;
    }
    $self->AsciiText($string, undef, $align);
    $self->End if $appearance || $font;
    return $self;
}

sub fixtext {
    my $self = shift;
    $self->Separator;
    $self->VRML_row("AxisAlignment { fields [SFBitMask alignment] alignment ALIGNAXISXYZ }\n");
    $self->text(@_);
    $self->end();
}
#--------------------------------------------------------------------

sub appearance {
    my $self = shift;
    my ($appearance_list) = @_;
    return $self unless $appearance_list;
    my ($item,$color,$multi_color,$key,$value,$num_color,$texture,%material,$name);
    ITEM:
    foreach $item (split(/\s*;\s*/,$appearance_list)) {
	($key,$value) = split(/\s*[=:]\s*/,$item,2);
	unless ($value) {	# color only
	    $value = $key;
	    $key = "diffuseColor";
	}
	MODE: {
	    if ($key eq "d")  { $key = "diffuseColor";  last MODE; }
	    if ($key eq "e")  { $key = "emissiveColor"; last MODE; }
	    if ($key eq "s")  { $key = "specularColor"; last MODE; }
	    if ($key eq "ai" || $key eq "a")  { $key = "ambientColor";  last MODE; }
	    if ($key eq "sh") { $key = "shininess";     last MODE; }
	    if ($key eq "tr") { $key = "transparency";  last MODE; }
	    if ($key eq "tex") { $texture = $value; next ITEM; }
	    if ($key eq "def" || $key eq "name") { $name = $value; next ITEM; }

	}
	if ($value =~ /,/) {	# multi color field
	    foreach $color (split(/\s*,\s*/,$value)) {
	    	($num_color,$color) = rgb_color($color);
		$value = "$num_color,";
	    	$value .= "	# $color" if $color;
	    	push @values, $value;
	    }
	    $material{$key} = [@values];
	    $multi_color = 1;	
	} else {
	    ($num_color,$color) = rgb_color($value);
	    $value = $num_color;
	    $value .= "	# $color" if $color;
	    $material{$key} = $value;
	}
    }
    $self->def($name) if $name;
    $self->Material(%material);
    $self->MaterialBinding("PER_PART") if $multi_color;
    $self->Texture2(split(/\s+/,$texture)) if defined $texture;
    return $self;
}


#--------------------------------------------------------------------

sub transform_begin {
    my $self = shift;
    return $self->Separator unless @_;
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
	    $rad *= $::pi/180 if abs($rad) > 2*$::pi;
	    $r = "$x $y $z $rad";
	}
    }
    $self->Separator->Transform($t,$r,$f,$o,$c);
    return $self;
}

sub transform_end {
    my $self = shift;
    $self->End();
    return $self;
}

#--------------------------------------------------------------------

sub sound {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->sound("url", "description", ...)\n}) unless @_;
    my ($url, $description, $location, $direction, $intensity, $loop, $pitch, $pause) = @_;
    $loop = defined $loop && $loop ? "TRUE" : "FALSE";
    $self->DirectedSound($url, $description, $location, $direction, $intensity, 100, 0, 0, 0, $loop);
    return $self;
}

#--------------------------------------------------------------------

sub def {
    my $self = shift;
    my ($name, $code) = @_;
    $name = "DEF_".(++$self->{'ID'}) unless defined $name;
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
    return $self->VRML_put(qq{# CALL: ->use("name");\n}) unless @_;
    my ($name) = @_;
    $self->USE($name);
    return $self;
}

sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*:://g;
    return $self->VRML_row(qq{### "$AUTOLOAD" unknown or not supported by VRML1.pm\n});
}

1;

__END__

=head1 NAME

VRML::VRML1.pm - implements VRML methods with the VRML 1.x standard

=head1 SYNOPSIS

    use VRML::VRML1;

=head1 DESCRIPTION

Following methods are currently implemented. (Values in '...' must be strings!)

=over 4

=item *
begin('comment')

C<  . . . >

=item *
end('comment')

=item *
group_begin('comment')

C<  . . . >

=item *
group_end

=item *
at('type=value ; ...')

parameter see C<transform_begin>

=item *
back

=item *
transform_begin('type=value ; ...')

I<Where type can be:>

	t = translation
	r = rotation
	c = center
	o = scaleOrientation
	f = scaleFactor

=item *
transform_end

=item *
anchor_begin('URL','description','target=parameter')

=item *
anchor_end

=item *
collision_begin

=item *
collision_end

=item *
lod_begin('range','center')

=item *
lod_end

=item *
background('color','imageURL')

=item *
title('string')

=item *
info('string')

=item *
cameras_begin('whichCameraNumber')

=item *
camera('name','positionXYZ','orientationXYZ',heightAngle) // persp. camera

=item *
camera_set('positionXYZ','orientationXYZ',heightAngle) // persp. cameras

=item *
camera_auto_set

=item *
cameras_end

=item *
light('direction','intensity','color','ambientIntensity','on') 

=item *
box('width [height [depth]]','appearance')

=item *
cone('radius height','appearance')

=item *
cube('width','appearance')

=item *
cylinder('radius [height]','appearance')

=item *
line('fromXYZ','toXYZ',radius,'appearance','[x][y][z]')

=item *
sphere('radius_x [radius_y radius_z]','appearance')

=item *
text('string','appearance','size style family')

=item *
fixtext('string','appearance','size style family')

=item *
def('name',[code])

=item *
use('name')

=item *
appearance('type=value1,value2 ; ...')

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

VRML::VRML1::Standard

VRML::Basic

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut
