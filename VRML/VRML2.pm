package VRML::VRML2;

require 5.000;
require VRML::VRML2::Standard;
use strict;
use VRML::Color;
use vars qw(@ISA $VERSION %supported);
@ISA = qw(VRML::VRML2::Standard);

$VERSION="1.02";
%supported = ('quote' => "Live3D|Cosmo Player",
	      'gzip'   => "Live3D|WorldView|Cosmo Player|VRweb|GLview",
	      'target' => "Live3D|WorldView|Cosmo Player",
	      'frames' => "Netscape|Mozilla|Internet Explorer|MSIE"
);

#--------------------------------------------------------------------

sub new {
    my $class = shift;
    my $version = shift;
    my $self = new VRML::VRML2::Standard($version);
    $self->{'browser'} = "";
    $self->{'viewpoint'} = [];
    return bless $self, $class;
}

sub browser {
    my $self = shift;
    return unless $_[0]; # @_ wouldn't work on PC
    ($self->{'browser'}) = join("+",@_);
    $self->VRML_put("# Set Browser to: '$self->{'browser'}'\n") if $self->{'DEBUG'};
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
sub begin {
    my $self = shift;
    $self->Group(@_);
    return $self;
}

sub end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub anchor_begin {
    my $self = shift;
    my ($url, $description, $parameter, $bboxSize, $bboxCenter) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $description =~ s/"/$quote/g if defined $description;
    $parameter =~ s/"/$quote/g if defined $parameter;
    undef $parameter if $self->{'browser'} !~ /$supported{'target'}/i;
    $self->Anchor($url, $description, $parameter, $bboxSize, $bboxCenter);
    return $self;
}

sub anchor_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub billboard_begin {
    my $self = shift;
    $self->Billboard(@_);
    return $self;
}

sub billboard_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub collision_begin {
    my $self = shift;
    my ($collide, $proxy) = @_;
    $collide = defined $collide && $collide ? "TRUE" : "FALSE";
    $self->Collision($collide, $proxy);
    return $self;
}

sub collision_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub group_begin {
    my $self = shift;
    $self->Group(@_);
    return $self;
}

sub group_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub lod_begin {
    my $self = shift;
    $self->LOD(@_);
    return $self;
}

sub lod_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub switch_begin {
    my $self = shift;
    $self->Switch(@_);
    return $self;
}

sub switch_end {
    my $self = shift;
    $self->EndChildren->End($_[0]); #  close [ and {
    return $self;
}

sub at {
    my $self = shift;
    $self->transform_begin(@_);
    return $self;
}

sub back {
   my $self = shift;
    $self->transform_end;
    return $self;
}

sub transform_begin {
    my $self = shift;
    my (@transform_list) = @_;
    my @transform;
    if (ref($transform_list[0])) {
	@transform = @{$transform_list[0]};
    } else {
	@transform = @transform_list;
    }
    return $self->Transform unless @transform;
    my ($item, $key, $value);
    my ($x,$y,$z,$angle,$t,$r,$s,$o,$c,$bbs,$bbc);
    foreach $item (@transform) {
	next if $item eq "";
	($key,$value) = ref($item) ? @$item : split(/\s*=\s*/,$item);
	unless ($value) {
	    ($x,$y,$z) = split(/\s/,$key);
	    $x=0 unless defined $x;
	    $y=0 unless defined $y;
	    $z=0 unless defined $z;
	    $t = "$x $y $z";
	}
	MODE: {
	    if ($key eq "t" || $key eq "translation") { $t = $value; last MODE; }
	    if ($key eq "r" || $key eq "rotation") { $r = $value; last MODE; }
	    if ($key eq "c" || $key eq "center") { $c = $value; last MODE; }
	    if ($key eq "s" || $key eq "scale") { $s = $value; last MODE; }
	    if ($key eq "so" || $key eq "scaleOrientation") { $o = $value; last MODE; }
	    if ($key eq "bbs" || $key eq "bboxSize") { $bbs = $value; last MODE; }
	    if ($key eq "bbc" || $key eq "bboxCenter") { $bbc = $value; last MODE; }
	}
	if ($key eq "r" || $key eq "rotation") {
	    ($x,$y,$z,$angle) = split(/\s/,$value);
	    unless ($angle) { # if not komplet assume first param is angle
		$angle=$x;
		$x=0;
		$y=0;
		$z=1;
	    }
	    $angle *= $::pi/180 if $self->{'CONVERT'};
	    $r = "$x $y $z $angle";
	}
    }
    $self->Transform($t,$r,$s,$o,$c,$b);
    return $self;
}

sub transform_end {
    my $self = shift;
    $self->EndTransform("Transform");
    return $self;
}

sub inline {
    my $self = shift;
    $self->Inline(@_);
    return $self;
}

#--------------------------------------------------------------------
#   VRML Methods
#--------------------------------------------------------------------

sub background {
    my $self = shift;
    my %hash = @_;
    my ($key,$value,@list);
    if (defined $hash{'skyColor'}) {
	if (ref($hash{'skyColor'}) eq "ARRAY") {
	    @list = ();
	    for $key (@{$hash{'skyColor'}}) {
		$value = rgb_color($key);
		push(@list, $value);
	    }
	    $hash{'skyColor'} = "[ ".join(", ",@list)." ]";
	    if (defined $hash{'skyAngle'}) {
		if (ref($hash{'skyAngle'}) eq "ARRAY") {
		    @list = ();
		    for $key (@{$hash{'skyAngle'}}) {
			$key *= $::pi/180 if $self->{'CONVERT'};
			push(@list, $key);
		    }
		    $hash{'skyAngle'} = "[ ".join(", ",@list)." ]";
		} else {
		    $hash{'skyAngle'} *= $::pi/180 if $self->{'CONVERT'};
		}
	    }
	} else {
	    $hash{'skyColor'} = rgb_color($hash{'skyColor'});
	}
    }
    if (defined $hash{'groundColor'}) {
	if (ref($hash{'groundColor'}) eq "ARRAY") {
	    @list = ();
	    for $key (@{$hash{'groundColor'}}) {
		$value = rgb_color($key);
		push(@list, $value);
	    }
	    $hash{'groundColor'} = "[ ".join(", ",@list)." ]";
	    if (defined $hash{'groundAngle'}) {
		if (ref($hash{'groundAngle'}) eq "ARRAY") {
		    @list = ();
		    for $key (@{$hash{'groundAngle'}}) {
			$key *= $::pi/180 if $self->{'CONVERT'};
			push(@list, $key);
		    }
		    $hash{'groundAngle'} = "[ ".join(", ",@list)." ]";
		} else {
		    $hash{'groundAngle'} *= $::pi/180 if $self->{'CONVERT'};
		}
	    }
	} else {
	    $hash{'groundColor'} = rgb_color($hash{'groundColor'});
	}
    }
    foreach $key (keys %hash) { $hash{$key} = "\"$hash{$key}\"" if $key =~ /Url$/; }
    $self->Background(%hash);
    return $self;
}

sub backgroundcolor {
    my $self = shift;
    my ($skyColorString, $groundColorString) = @_;
    my ($skyColor, $groundColor);
    $skyColor = rgb_color($skyColorString) if defined $skyColorString;
    $groundColor = rgb_color($groundColorString) if defined $groundColorString;
    $self->Background(skyColor => $skyColor, groundColor => $groundColor);
    return $self;
}

sub backgroundimage {
    my $self = shift;
    my ($url) = @_;
    return unless $url;
    $self->Background(
	frontUrl => "\"$url\"",
	leftUrl => "\"$url\"",
	rightUrl => "\"$url\"",
	backUrl => "\"$url\"",
	bottomUrl => "\"$url\"",
	topUrl => "\"$url\""
    );
    return $self;
}

sub title {
    my $self = shift;
    my $title = shift;
    return unless defined $title;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $title =~ s/"/$quote/g;
    $self->WorldInfo($title);
    return $self;
}

sub info {
    my $self = shift;
    my ($info) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    if (defined $info) {
	$info =~ s/"/$quote/g;
        $self->WorldInfo(undef, $info);
    }
    return $self;
}

sub worldinfo {
    my $self = shift;
    my ($title, $info) = @_;
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    $title =~ s/"/$quote/g if defined $title;
    $info =~ s/"/$quote/g if defined $info;
    $self->WorldInfo($title, $info);
    return $self;
}

sub navigationinfo {
    my $self = shift;
    my ($type, $speed, $headlight, $visibilityLimit, $avatarSize) = @_;
    $headlight = defined $headlight && !$headlight ? "FALSE" : "TRUE";
    $self->NavigationInfo($type, $speed, $headlight, $visibilityLimit, $avatarSize);
    return $self;
}
#--------------------------------------------------------------------

sub viewpoint_begin {
    my $self = shift;
    my ($whichChild) = @_;
    $whichChild = (defined $whichChild && $whichChild > 0) ? $whichChild-1 : 0;
    $self->{'TAB_VIEW'} = $self->{'TAB'};
    $self->{'viewpoint_begin'} = $#{$self->{'VRML'}}+1 unless defined $self->{'viewpoint_begin'};
    return $self;
}

sub viewpoint_end {
    my $self = shift;
    splice(@{$self->{'VRML'}}, $self->{'viewpoint_begin'}, 0, @{$self->{'viewpoint'}});
    $self->{'viewpoint'} = [];
    return $self;
}

sub viewpoint_auto_set {
    my $self = shift;
    my $factor = shift;
    $factor = 1 unless defined $factor;
    if (defined $self->{'viewpoint_set'}) {
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
	my $offset = $#{$self->{'viewpoint'}}+1;
	$self->viewpoint_set("$x $y $z",$dist*$factor,60);
	@_ = splice(@{$self->{'viewpoint'}}, $offset);
	splice(@{$self->{'viewpoint'}}, $self->{'viewpoint_set'}, $#_+1, @_);
    } else {
	$self->viewpoint_set(@_);
    }
    return $self;
}

sub viewpoint_set {
    my $self = shift;
    my ($center, $distance, $fieldOfView) = @_;
    $self->{'viewpoint_set'} = $#{$self->{'viewpoint'}}+1 unless defined $self->{'viewpoint_set'};
    my ($x, $y, $z) = split(/\s+/,$center) if defined $center;
    my ($dx, $dy, $dz) = defined $distance ? split(/\s+/,$distance) : (0,0,0);
    $x = 0 unless defined $x;
    $y = 0 unless defined $y;
    $z = 0 unless defined $z;
    $dx = 1 unless defined $dx;
    $dy = $dx unless defined $dy;
    $dz = $dx unless defined $dz;
    $self->viewpoint("Front", "$x $y ".($z+$dz), "0 0 1 0",$fieldOfView);
    $self->viewpoint("Right", ($x+$dx)." $y $z", "0 1 0 90",$fieldOfView);
    $self->viewpoint("Back", "$x $y ".($z-$dz), "0 1 0 180",$fieldOfView);
    $self->viewpoint("Left", ($x-$dx)." $y $z", "0 1 0 -90",$fieldOfView);
    $self->viewpoint("Top", "$x ".($y+$dy)." $z", "1 0 0 -90",$fieldOfView);
    $self->viewpoint("Bottom", "$x ".($y-$dy)." $z", "1 0 0 90",$fieldOfView);
    return $self;
}

sub viewpoint {
    my $self = shift;
    my ($description, $position, $orientation, $fieldOfView, $jump) = @_;
    if (defined $orientation) {
	 if ($orientation !~ /\s/) {
	    my %val = ("FRONT" => "0 0 1 0", "BACK" => "0 1 0 3.14",
	    	"RIGHT" => "0 1 0  1.57", "LEFT" => "0 1 0 -1.57",
		"TOP" => "1 0 0 -1.57",	"BOTTOM" => "1 0 0 1.57");
	    my $string = uc($orientation);
	    undef $orientation;
	    $orientation = $val{$string};
            $orientation .= " # $string" if $orientation;
	} else {
	    my ($x,$y,$z,$angle) = ref($orientation) ? @$orientation : split(/\s+/,$orientation);
	    if (defined $angle) {
		$angle *= $::pi/180 if $self->{'CONVERT'};
		$orientation = "$x $y $z $angle";
	    }
	}
    }
    $fieldOfView *= $::pi/180 if defined $fieldOfView && $self->{'CONVERT'};
    if (defined $jump) { $jump = $jump ? "TRUE" : "FALSE"; }
    $self->{'TAB_VIEW'} = $self->{'TAB'} unless $self->{'TAB_VIEW'};
    if ($description =~ /^#/) {
	$description =~ s/^#//;
	my ($name) = $description;
	$name =~ s/[\x00-\x20\x7f\x22\x27\x23\x2c\x2e\x5b\x5d\x5c\x7b\x7d\x30-\x39\x2b\x2d]/_/g;
        push @{$self->{'viewpoint'}}, $self->{'TAB_VIEW'}."DEF $name\n";
    }
    $self->Viewpoint($description, $position, $orientation, $fieldOfView, $jump);
    push @{$self->{'viewpoint'}}, pop @{$self->{'VRML'}};
    unless (defined $self->{'viewpoint_begin'}) {
	splice(@{$self->{'VRML'}}, @{$self->{'VRML'}}, 0, @{$self->{'viewpoint'}});
	$self->{'viewpoint'} = [];
    }
    return $self;
}

#--------------------------------------------------------------------

sub directionallight {
    my $self = shift;
    my ($direction, $intensity, $ambientIntensity, $color, $on) = @_;
    if (defined $on) { $on = $on ? "TRUE" : "FALSE"; }
    $color = rgb_color($color) if defined $color;
    $self->DirectionalLight($direction, $intensity, $ambientIntensity, $color, $on);
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
    $self->comment('line("'.join('", "',@_).'")');
    $self->Group();
    if (defined $radius && $radius>0) {
	if ($dx && $order =~ /x/) {
	    $t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x$/i;
	    $t = ($x1-($dx/2))." $y1 $z1" if $order =~ /^x../i;
	    $t = ($x1-($dx/2))." $y2 $z1" if $order =~ /yxz/i;
	    $t = ($x1-($dx/2))." $y1 $z2" if $order =~ /zxy/i;
	    $t = ($x1-($dx/2))." $y2 $z2" if $order =~ /..x$/i;
	    $self->Transform($t,"0 0 1 $::pi_2");
	    $self->Shape(sub{$self->Cylinder($radius,abs($dx))},
		    sub{$self->appearance($appearance)});
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
		    sub{$self->appearance($appearance)});
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
		    sub{$self->appearance($appearance)});
	    $self->EndTransform;
	}
	unless ($order) {
	    $length = sqrt($dx*$dx + $dy*$dy + $dz*$dz);
	    $t = ($x1-($dx/2))." ".($y1-($dy/2))." ".($z1-($dz/2));
	    $r = "$dx ".($dy+$length)." $dz $::pi";
	    $self->Transform($t,$r);
	    $self->Shape(sub{$self->Cylinder($radius,$length)},
		    sub{$self->appearance($appearance)});
	    $self->EndTransform;
	}
    } else {
	my $color = rgb_color($appearance);
	$self->Shape(sub{$self->IndexedLineSet(
	    sub{$self->Coordinate($from,$to)},
	    "0 1","Color { color [ $color ] }",undef,"FALSE")});
    }
    $self->EndChildren->End("line");
    return $self;
}

#--------------------------------------------------------------------

sub box {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $self->Shape(
	sub{$self->Box("$width $height $depth")},
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
    $height = $width unless defined $height;
    $depth = $width unless defined $depth;
    $self->Shape(
	sub{$self->Box("$width $height $depth")},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub cylinder {
    my $self = shift;
    my ($dimension, $appearance, $top, $side, $bottom) = @_;
    my ($radius, $height) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    $top = $top ? "TRUE" : "FALSE" if defined $top;
    $side = $side ? "TRUE" : "FALSE" if defined $side;
    $bottom = $bottom ? "TRUE" : "FALSE" if defined $bottom;
    $self->Shape(
	sub{$self->Cylinder($radius, $height, $top, $side, $bottom)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub elevationgrid {
    my $self = shift;
    my ($height_ref, $color, $xDimension, $zDimension, $xSpacing, $zSpacing) = @_;
    $xDimension = ($$height_ref[0] =~ s/\s+/ /g) + 1 unless defined $xDimension;
    $zDimension = @$height_ref unless defined $zDimension;
    $xSpacing = 1 unless defined $xSpacing;
    $zSpacing = $xSpacing unless defined $zSpacing;
    $self->ElevationGrid($xDimension, $zDimension, $xSpacing, $zSpacing, $height_ref, $color);
    return $self;
}

sub indexedfaceset {
    my $self = shift;
    my ($coord, $coordIndex, $appearance, $color, $colorIndex) = @_;
    $colorIndex = [0..$#{@$color}] unless defined $colorIndex;
    my @color = split(",",$appearance);
    $self->Shape(
	sub{$self->IndexedFaceSet(
	    sub{$self->Coordinate($coord)}, $coordIndex,
	    sub{$self->color(@color)}, $colorIndex, "FALSE")
	},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub pyramid {
    my $self = shift;
    my ($dimension, $appearance) = @_;
    my ($width,$height,$depth) = ref($dimension) ? @$dimension : split(/\s+/,$dimension);
    my $x_2 = $width/2;
    my $y_2 = $height/2;
    my $z_2 = defined $depth ? $depth/2 : $x_2;
    my @color = split(",",$appearance) if $appearance;
    my @color_prop = ();
    @color_prop = (sub{$self->color(@color)},[0..4],"FALSE") if $#color > 0;
    $self->Shape(
	sub{$self->IndexedFaceSet(
	    sub{$self->Coordinate("-$x_2 -$y_2 $z_2","$x_2 -$y_2 $z_2","$x_2 -$y_2 -$z_2","-$x_2 -$y_2 -$z_2","0 $y_2 0")},
	    ["0, 1, 4","1, 2, 4","2, 3, 4","3, 0, 4","0, 3, 2, 1"],@color_prop)
	},sub{$self->appearance($appearance)}
    );
    return $self;
}

sub sphere {
    my $self = shift;
    my ($radius, $appearance) = @_;
    $self->Shape(
	sub{$self->Sphere($radius)},
	sub{$self->appearance($appearance)}
    );
    return $self;
}

sub text {
    my $self = shift;
    my ($string, $appearance, $font, $align) = @_;
    my ($size, $family, $style);
    my $quote = $self->{'browser'} =~ /$supported{'quote'}/i ? '\\"' : "'";
    if (defined $string) {
	if (ref($string)) {
	    map { s/"/$quote/g } @$string;
	    $string = '["'.join('","',@$string).'"]';
	} else {
	    $string =~ s/"/$quote/g;
	    $string = "\"$string\"";
	}
    }
    $self->Shape(sub{
      if (defined $font || defined $align) {
	if (defined $font) {
	    ($size, $family, $style) = split(/\s+/,$font,3); # local variable !!!
	}
	if (defined $align) {
	    $align =~ s/LEFT/BEGIN/i;
	    $align =~ s/CENTER/MIDDLE/i;
	    $align =~ s/RIGHT/END/i;
	}
	$self->Text($string,sub{$self->FontStyle($size, $family, $style, $align)});
      } else {
	$self->Text($string);
      }},sub{$self->appearance($appearance)}
    );
    return $self;
}

sub billtext {
    my $self = shift;
    my @param = @_;
    $self->Billboard("0 0 0",sub{$self->text(@param)}); # don't use @_ directly
}
#--------------------------------------------------------------------

sub color {
    my $self = shift;
    my ($rgb, $comment, @colors);
    for (@_) {
	($rgb, $comment) = rgb_color($_);
	push(@colors, $rgb);
    }
    $self->Color(@colors);
    return $self;
}
#--------------------------------------------------------------------

sub appearance {
    my $self = shift;
    my ($appearance_list) = @_;
    return $self->VRML_put("Appearance {}\n") unless $appearance_list;
    my $texture = "";
    my ($item,$color,$multi_color,$key,$value,@values,$num_color,%material,$name,$def);
    ITEM:
    foreach $item (split(/\s*;\s*/,$appearance_list)) {
	($key,$value) = ref($item) ? @$item : split(/\s*=\s*/,$item,2);
#	($key,$value) = split(/\s*=\s*/,$item,2);
	unless ($value) {	# color only
	    $value = $key;
	    $key = "diffuseColor";
	}
	MODE: {
	    if ($key eq "d")  { $key = "diffuseColor";  last MODE; }
	    if ($key eq "e")  { $key = "emissiveColor"; last MODE; }
	    if ($key eq "s")  { $key = "specularColor"; last MODE; }
	    if ($key eq "ai") { $key = "ambientIntensity";  last MODE; }
	    if ($key eq "sh") { $key = "shininess";     last MODE; }
	    if ($key eq "tr") { $key = "transparency";  last MODE; }
	    if ($key eq "tex") { $texture = $value; next ITEM; }
	    if ($key eq "def") { $def = $value; next ITEM; }
	    if ($key eq "name") { $name = $value; next ITEM; }
	    if ($key eq "use") {
		$self->use($value);
	        return $self;
	    }
	}
	if ($key eq "diffuseColor" | $key eq "emissiveColor" | $key eq "specularColor") {
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
	} else {
		$material{$key} = $value;
	}
    }
    $self->def($def) if $def;
    $self->Appearance(
	%material ? sub{$self->Material(%material)} : undef,
	$texture =~ /\.gif|\.jpg|\.png|\.bmp/i ? sub{$self->ImageTexture(split(/\s+/,$texture))} : undef ||
	$texture =~ /\.avi|\.mpg|\.mov/i ? sub{$self->def($name)->MovieTexture(split(/\s+/,$texture))} : undef
    );
    return $self;
}

#--------------------------------------------------------------------

sub sound {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->sound("url", "description", ...)\n}) unless @_;
    my ($url, $description, $location, $direction, $intensity, $loop, $pitch) = @_;
    $loop = defined $loop && $loop ? "TRUE" : "FALSE";
    $self->Sound(sub{$self->DEF($description)->AudioClip($url, $description, $loop, $pitch)->VRML_trim},
	$location, $direction, $intensity, 100 );
    return $self;
}

#--------------------------------------------------------------------

sub cylindersensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->cylindersensor("name")\n}) unless @_;
    my ($name) = shift;
    $self->def($name)->CylinderSensor(@_)->VRML_trim;
    return $self;
}

sub planesensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->planesensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->PlaneSensor(@_)->VRML_trim;
    return $self;
}

sub proximitysensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->proximitysensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->ProximitySensor(@_)->VRML_trim;
    return $self;
}

sub spheresensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->spheresensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->SphereSensor(@_)->VRML_trim;
    return $self;
}

sub timesensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->timesensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->TimeSensor(@_)->VRML_trim;
    return $self;
}

sub touchsensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->touchsensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->TouchSensor(@_)->VRML_trim;
    return $self;
}

sub visibitysensor {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->visibitysensor("name")\n}) unless @_;
    my $name = shift;
    $self->def($name)->VisibilitySensor(@_)->VRML_trim;
    return $self;
}

#--------------------------------------------------------------------

sub interpolator {
    my $self = shift;
    return $self->VRML_put(qq{# CALL: ->interpolator("name","type", [keys],[keyValues])\n}) unless @_;
    my $name = shift;
    my $type = shift;
    $type .= "Interpolator";
    $self->def($name)->$type(@_)->VRML_trim;
    return $self;
}

#--------------------------------------------------------------------
# other
#--------------------------------------------------------------------

sub route {
    shift->ROUTE(@_);
}

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
    return $self->VRML_put(qq{# CALL: ->use("name")\n}) unless @_;
    my ($name) = @_;
    $self->USE($name);
    return $self;
}

1;

__END__

=head1 NAME

VRML::VRML2.pm - VRML methods with the VRML 2.0 standard

=head1 SYNOPSIS

    use VRML::VRML2;

    $vrml = new VRML::VRML2;
    $vrml->browser('CosmoPlayer 1.0','Netscape');
    $vrml->at('-15 0 20');
    $vrml->box('5 3 1','yellow');
    $vrml->back;
    $vrml->print;
    $vrml->save;

  OR with the same result

  use VRML::VRML2;

  VRML::VRML2->new
  ->browser('CosmoPlayer 1.0','Netscape')
  ->at('-15 0 20')->box('5 3 1','yellow')->back
  ->print->save;

=head1 DESCRIPTION

The methods of this module are easier to use than the VRML::*::Standard methods
because the methods are on a higher level. For example you can use X11 color
names and it's simple to apply textures to an object. All angles could be
assigned in degrees.

If a method does the same like its VRML pedant then it has the same name but in
lowercase (e.g. box). The open part of a group method ends with a
_begin (e.g. anchor_begin). The closing part ends with an _end (e.g.
anchor_end). For a detailed description how the generated node works, take a 
look at the VRML 2.0 specification on VAG.

Following methods are currently implemented. (Values in '...' must be strings!)

=over 4

=item *
begin('comment')

Before you use an geometry or transform method please call this method.
It's necessary to calculate something at the end.

=item *
end('comment')

After C<end> there should no geometry or transformation. This method completes
the calculations of viewpoints etc.

=item *
at('type=value','type=value', ...)

is the short version of the method C<transform_begin>. It has the same 
parameters as C<transform_begin>.

=item *
back

is the short version of the method C<transform_end>.

=item *
anchor_begin('url','description','parameter')

=item *
anchor_end

=item *
billboard_begin('axisOfRotation')

=item *
billboard_end

=item *
collision_begin(collide,proxy)

=item *
collision_end

=item *
group_begin('comment')

=item *
group_end

=item *
lod_begin(range,'center')

=item *
lod_end

=item *
switch_begin(whichChoice)

=item *
switch_end

=item *
transform_begin('type=value','type=value', ...)

I<Where type can be:>

	t = translation
	r = rotation
	c = center
	s = scale
	so = scaleOrientation
	bbs = bboxSize
	bbc = bboxCenter

=item *
transform_end

=item *
inline('Url')

=item *
background(

	skycolor => '...',
	groundcolor => '...',
	bottomUrl => '...',
	topUrl => '...',
	frontUrl => '...',
	leftUrl => '...',
	rightUrl => '...',
	backUrl => '...'

)

This is a parameter hash. Only use the parts you need.

=item *
backgroundcolor('skyColor','groundColor')

is the short version of C<background>. It specifies only colors.

=item *
backgroundimage('Url')

is the short version of C<background>. It needs only one image. The
given Url will assigned to all parts of the background cube.

=item *
title('string')

=item *
info('string')

=item *
viewpoint_begin

starts the hidden calculation of viewpoint center and distance for the
method C<viewpoint_auto_set()>. It collects also the viepoints to place
they in the first part of the VRML source.

=item *
viewpoint('description','position','orientation',fieldOfView,jump)

=item *
viewpoint_set('center','distance',fieldOfView)

places six viewpoints around the center.

=item *
viewpoint_auto_set

sets all parameters of C<viewpoint_set> automatically.

=item *
viewpoint_end

=item *
directionallight('direction',intensity,ambientIntensity,'color',on)

=item *
box('width height depth','appearance')

=item *
cone('radius height','appearance')

=item *
cube(length,'appearance')

does the same as method C<box>, but needs only one parameter.

=item *
cylinder('radius [height]','appearance')

=item *
line('fromXYZ','toXYZ',radius,'appearance','[x][y][z]')

draws a line (cylinder) between two points with a given radius. If radius
is '0' only a hairline will be printed. The last parameter specifies the
devolution along the axes. An empty stands for direct connection.

=item *
sphere(radius_x,'appearance')

=item *
text('string','appearance','size family style','align')

=item *
billtext('string','appearance','size family style','align')

does the same like method C<text>, but the text better readable.

=item *
appearance('type=value1,value2 ; type=...')

The appearance method specifies the visual properties of geometry by defining
the material and texture. If more than one type is needed separate the types
by semicolon. The types can choosen from the following list.
 
Note: one character mnemonic are colors
      two characters mnemonic are values in range of [0..1]
      more characters are strings like file names or labels

	d = diffuseColor
	e = emissiveColor
	s = specularColor
	ai = ambientIntensity
	sh = shininess
	tr = transparency
	tex = texture filename,wrapS,wrapT
	name = names the MovieTexture node (for a later route)

The color values can be strings (X11 color names) or RGB-triples. It is 
possible to reduce the intensity of colors (names) by appending a two digit
value (percent). This value must be separated by an underscore (_) or
a percent symbol (%). Note: Do not use a percent symbol in URL's. It would
be decoded in an ascii character.

Sample (valid color values):
	'1 1 0' # VRML standard
	'FFFF00' or 'ffff00', '255 255 0', 'yellow'

or reduced to 50%
	'.5 .5 .5' # VRML standard
	'808080', '128 128 0', 'yellow%50' or 'yellow_50'


For a list of I<X11 color names> take a look at VRML::Color

=item *
def('name',[code])


=item *
use('name')

=item *
route('from','to')

=item *
interpolator('name','type',[keys],[keyValues])

I<Where type can be:>

	Color
	Coordinate
	Orientation
	Normal
	Position
	Scalar
	

=item *
cylindersensor('name',maxAngle,minAngle,diskAngle,offset,autoOffset,enabled)

=item *
planesensor('name',maxPosition,minPosition,offset,autoOffset,enabled)

=item *
proximitysensor('name',size,center,enabled)

=item *
spheresensor('name',offset,autoOffset,enabled)

=item *
timesensor('name',cycleInterval,loop,startTime,stopTime,enabled)

=item *
touchsensor('name',enabled)

=item *
visibitysensor('name',size,center,enabled)

=back

=head1 SEE ALSO

VRML

VRML::VRML2::Standard

VRML::Base

http://www.gfz-potsdam.de/~palm/vrmlperl/ for a description of F<VRML-modules> and how to obtain it.

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

Homepage http://www.gfz-potsdam.de/~palm/

=cut
