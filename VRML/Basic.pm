package VRML::Basic;

require 5.000;
use strict;

# $VERSION = "0.90";
$::debug = 0 unless defined $::debug;
$::pi = 3.1415926;
$::pi_2 = $::pi/2;
$::pi_2 += 0 if 0;

sub new {
    my $class = shift;
    my $tabs = shift;
    my $self = {};
    $self->{'TAB'} = defined $tabs ? "\t" x $tabs : "";
    $self->{'TAB_VIEW'} = "";
    $self->{'SELF'} = 1;
    $self->{'HEAD'} = "";
    $self->{'VRML'} = [];
    $self->{'VIEW'} = [];
    $self->{'DEF'}  = {};
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

sub debug {
    my $self = shift;
    $::debug = shift;
    $self->VRML_put("# Set Debug Level to: '$::debug'\n");
    return $self;
}    

sub display_vars {
    my $self = shift;
    my @keys = @_ ? @_ : sort keys %$self;
    my $key;
    foreach $key (@keys) {
	unless (defined $self->{$key}) {
	    print "# $key => undef";
	    next;
	}
	print "# $key => $self->{$key}";
	print " [".(join(', ',@{$self->{$key}}))."]" if defined ref($self->{$key}) && ref($self->{$key}) eq "ARRAY" && $key ne "VRML";
	print " [".(join(', ',sort keys %{$self->{$key}}))."]" if defined ref($self->{$key}) && ref($self->{$key}) eq "HASH";
	print "\n";
    }
    return $self;
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
    $self->{'HEAD'} = "$vrml\n\n";
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

sub VRML_trim {
    my $self = shift;
    my ($index) = @_;
    $index = $#{$self->{'VRML'}} unless defined $index;
    $self->{'VRML'}[$index-1] =~ s/\s+$/ /;
    $self->{'VRML'}[$index] =~ s/^\s+//;
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
    print $self->{'HEAD'};
    for (@{$self->{'VRML'}}) { print ascii($_); }
    return $self if $self->{'SELF'};
    return "";
}

sub VRML_format {
    my $self = shift;
    my $name;
    for (@{$self->{'VRML'}}) { }
    return $self if $self->{'SELF'};
    return "";
}

#--------------------------------------------------------------------

sub print {
    my $self = shift;
    $self->VRML_print;
    return $self;
}

sub save {
    my $self = shift;
    my $filename = shift;
    $filename = "$0.wrl" unless $filename;
    open(VRMLFILE, ">$filename");
    print VRMLFILE $self->as_string;
    close(VRMLFILE);
    return $self;
}

sub as_string {
    my $self = shift;
    my $vrml = $self->{'HEAD'};
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
    print "XYZ = ".join(', ',@{$self->{'XYZ'}[0]})."\n" if $::debug == 2;
    $self->{'Xmax'} = ${$self->{'XYZ'}[0]}[0] if $self->{'Xmax'} < ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymax'} = ${$self->{'XYZ'}[0]}[1] if $self->{'Ymax'} < ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmax'} = ${$self->{'XYZ'}[0]}[2] if $self->{'Zmax'} < ${$self->{'XYZ'}[0]}[2];
    $self->{'Xmin'} = ${$self->{'XYZ'}[0]}[0] if $self->{'Xmin'} > ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymin'} = ${$self->{'XYZ'}[0]}[1] if $self->{'Ymin'} > ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmin'} = ${$self->{'XYZ'}[0]}[2] if $self->{'Zmin'} > ${$self->{'XYZ'}[0]}[2];
}

sub DEF {
    my $self = shift;
    my ($name) = @_;
    my $vrml = $self->{'TAB'}."DEF $name\n";
    push @{$self->{'VRML'}}, $vrml;
    $self->{'DEF'}{$name} = $#{$self->{'VRML'}};
    return $self if $self->{'SELF'};
    return $vrml;
}

sub USE {
    my $self = shift;
    my ($name) = @_;
    my $vrml = "";
    $vrml = $self->{'TAB'}."USE $name\n";
    push @{$self->{'VRML'}}, $vrml;
    return $self if $self->{'SELF'};
    return $vrml;
}

1;

__END__


=head1 NAME

VRML::Basic.pm - implements basic methods

=head1 SYNOPSIS

    use VRML::Basic;

=head1 DESCRIPTION

Following methods are currently implemented.

=over 4

=item USE

C<USE($name)>

=item DEF

C<DEF($name)>

=back

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut

