package VRML::Base;

require 5.000;
use strict;
use vars qw($VERSION);

$VERSION = "1.03de";
$::pi = 3.1415926;
$::pi_2 = $::pi/2;
$::pi_2 += 0; # prevent warnings

sub new {
    my $class = shift;
    my $tabs = shift;
    my $self = {};
    $self->{'TAB'} = defined $tabs ? "\t" x $tabs : "";
    $self->{'TAB_VIEW'} = "";
    $self->{'DEBUG'} = 0;
    $self->{'VERSION'} = 0; # VRML specification
    $self->{'CONVERT'} = 1; # convert degree to radiant
    $self->{'BROWSER'} = "";# Which VRML + HTML browser
    $self->{'VRML'} = [];   # THE VRML array
    $self->{'DEF'}  = {};   # remember DEFs
    $self->{'PROTO'} = {};  # remember PROTOs
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
    $self->{'ID'}  = 0;
    return bless $self, $class;
}

sub browser {
    my $self = shift;
    return unless $_[0]; # @_ wouldn't work on PC
    ($self->{'BROWSER'}) = join("+",@_);
    $self->VRML_put("# Set Browser to: '$self->{'browser'}'\n")
      if $self->{'DEBUG'};
    return $self;
}

#####################################################################
#               Methods to modify the VRML array
#
#####################################################################

sub VRML_init {
    my $self = shift;
    my $vrml = shift;
    $self->{'VRML'} = [$vrml];
    return $self;
}

sub VRML_add {
    my $self = shift;
    my $vrml = shift;
    ${$self->{'VRML'}}[$#{$self->{'VRML'}}] .= $vrml;
    return $self;
}

sub VRML_put {
    my $self = shift;
    my $vrml = shift;
    push @{$self->{'VRML'}}, $vrml;
    return $self;
}

sub VRML_row {
    my $self = shift;
    my ($row) = @_;
    my $vrml = $self->{'TAB'}.$row;
    push @{$self->{'VRML'}}, $vrml;
    return $self;
}

sub VRML_swap {
    my $self = shift;
    my $element1 = pop @{$self->{'VRML'}};
    my $element2 = pop @{$self->{'VRML'}};
    push @{$self->{'VRML'}}, $element1;
    push @{$self->{'VRML'}}, $element2;
    return $self;
}

sub VRML_pos {
    my $self = shift;
    return $#{$self->{'VRML'}};
}

sub VRML_trim {
    my $self = shift;
    my ($index) = @_;
    $index = $#{$self->{'VRML'}} unless defined $index;
    $self->{'VRML'}[$index-1] =~ s/\s+$/ /;
    $self->{'VRML'}[$index] =~ s/^\s+//;
    return $self;
}

sub debug {
    my $self = shift;
    $self->{'DEBUG'} = shift;
    $self->VRML_put("# Set Debug Level to: $self->{'DEBUG'}\n");
    return $self;
}

sub display_vars {
    my $self = shift;
    my @keys = @_ ? @_ : sort keys %$self;
    my $key;
    foreach $key (@keys) {
	unless (defined $self->{$key}) {
	    print "# $key => undef\n";
	    next;
	}
	print "# $key => $self->{$key}";
	print " [".(join(', ',@{$self->{$key}}))."]" if defined
	  ref($self->{$key}) && ref($self->{$key}) eq "ARRAY" &&
	  $key ne "VRML";
	print " [".(join(', ',sort keys %{$self->{$key}}))."]"
	  if defined ref($self->{$key}) && ref($self->{$key}) eq "HASH";
	print "\n";
    }
    return $self;
}


#--------------------------------------------------------------------
#	Insert Comments
#--------------------------------------------------------------------
sub comment {
    my $self = shift;
    my ($comment) = @_;
    $comment = defined $comment ? "# ".$comment : "#";
    push @{$self->{'VRML'}}, $comment."\n";
    return $self;
}

#--------------------------------------------------------------------
#	In-/Output VRML
#--------------------------------------------------------------------
sub insert {
    my $self = shift;
    my $string = shift;
    push @{$self->{'VRML'}}, $string."\n";
    return $self;
}

sub insert__DATA__ {
    my $self = shift;
    push @{$self->{'VRML'}}, <main::DATA>,"\n";
    return $self;
}

sub include {
    my $self = shift;
    my $filename = shift;
    return $self if !defined $filename || $filename eq "";
    open(INCLUDE, "<$filename") || die;
    push @{$self->{'VRML'}}, <INCLUDE>;
    close(INCLUDE);
    return $self;
}

sub print {
    my $self = shift;
    my $mime = shift;
    my $pipe = shift;
    select STDOUT; $|=1;
    print "Content-type: $self->{'Content-type'}\n\n"
      if $self->{'Content-type'} && $mime;
    if ($pipe) {
	open(PIPE, "|$pipe") || die; select PIPE; $|=1;
	for (@{$self->{'VRML'}}) { print; }
	select STDOUT;
	close(PIPE);
    } else {
	for (@{$self->{'VRML'}}) { print; }
    }
    return $self;
}

sub save {
    my $self = shift;
    my $filename = shift;
    my $pipe = shift;
    unless (defined $filename) {
	($filename) = $0 =~ m/(.*)\./;
	$filename .= ".wrl";
    }
    open(VRMLFILE, ">$filename") ||
      die "Can't create file: \"$filename\" ($!)\n";
    if ($pipe) {
	print VRMLFILE "Can't pipe to \"$pipe\"\n";
	close(VRMLFILE);
	open(VRMLFILE, "| $pipe > $filename") || die;
    }
    for (@{$self->{'VRML'}}) { print VRMLFILE; }
    close(VRMLFILE);
    return $self;
}

sub as_string {
    my $self = shift;
    my $vrml = "";
    for (@{$self->{'VRML'}}) { $vrml .= $_ };
    return $vrml;
}

#--------------------------------------------------------------------

sub escape {
    my $self = shift;
    shift;
}

sub ascii {
    my $self = shift;
    local $_ = shift;
    s/[\204\344\365]/ae/g;
    s/[\224\366]/oe/g;
    s/[\201\374]/ue/g;
    s/[\216\304]/Ae/g;
    s/[\231\305\326]/Oe/g;
    s/[\263\334]/Ue/g;
    s/[\257\337]/sz/g;
    s/[\000-\010\013-\037\177-\377]/_/g;
    return $_;
}

sub utf8 {
    my $self = shift;
    local $_ = shift;
    s/[\000-\010\013-\037]/_/g;
    return $_;
}

sub xyz {
    my $self = shift;
    return $self unless @_;
    ($self->{'DX'}, $self->{'DY'}, $self->{'DZ'}) = @_;
    ${$self->{'XYZ'}[0]}[0] += $self->{'DX'};
    ${$self->{'XYZ'}[0]}[1] += $self->{'DY'};
    ${$self->{'XYZ'}[0]}[2] += $self->{'DZ'};
    print "XYZ = ".join(', ',@{$self->{'XYZ'}[0]})."\n"
      if $self->{'DEBUG'} == 2;
    $self->{'Xmax'} = ${$self->{'XYZ'}[0]}[0]
      if $self->{'Xmax'} < ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymax'} = ${$self->{'XYZ'}[0]}[1]
      if $self->{'Ymax'} < ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmax'} = ${$self->{'XYZ'}[0]}[2]
      if $self->{'Zmax'} < ${$self->{'XYZ'}[0]}[2];
    $self->{'Xmin'} = ${$self->{'XYZ'}[0]}[0]
      if $self->{'Xmin'} > ${$self->{'XYZ'}[0]}[0];
    $self->{'Ymin'} = ${$self->{'XYZ'}[0]}[1]
      if $self->{'Ymin'} > ${$self->{'XYZ'}[0]}[1];
    $self->{'Zmin'} = ${$self->{'XYZ'}[0]}[2]
      if $self->{'Zmin'} > ${$self->{'XYZ'}[0]}[2];
}

sub bboxCenter {
    my $self = shift;
    my ($x, $y, $z) = @_;
    $x = ($self->{'Xmax'} + $self->{'Xmin'})/2 unless defined $x;
    $y = ($self->{'Ymax'} + $self->{'Ymin'})/2 unless defined $y;
    $z = ($self->{'Zmax'} + $self->{'Zmin'})/2 unless defined $z;
    return ($x, $y, $z) if wantarray;
    return "$x $y $z";
}

sub bboxSize {
    my $self = shift;
    my ($dx, $dy, $dz) = @_;
    $dx = $self->{'Xmax'} - $self->{'Xmin'} unless defined $dx;
    $dy = $self->{'Ymax'} - $self->{'Ymin'} unless defined $dy;
    $dz = $self->{'Zmax'} - $self->{'Zmin'} unless defined $dz;
    return ($dx, $dy, $dz) if wantarray;
    return "$dx $dy $dz";
}

1;

__END__


=head1 NAME

VRML::Base.pm - Basis-Methoden für die VRML 1 und 2 Module

=head1 SYNOPSIS

    use VRML::Base;

=head1 DESCRIPTION

Folgende Methoden stehen zur Verfügung.

=over 4

=item new

F<new>

erzeugt ein neues VRML-Szenen-Objekt. Diese Methode muß vor der Verwendung
einer weiteren Methode aufgerufen werden.

=item browser

F<browser("vrml", "html")>

 vrml SFString ""
 html SFString ""


Die Implementierung der VRML-Spezifikationen in den Browsern und Plug-ins ist
je nach Entwicklungsstand und Hersteller unterschiedlich. Um einige
allgemeine Besonderheiten berücksichtigen zu können und Anzeigefehler zu
verhindern, sollte deshalb der F<browser>-Methode der Name des VRML- und
HTML-Browsers mitgegeben werden. I<Leere Parameter> oder das Weglassen der
Methode bewirken die Verwendung des I<kleinsten vertretbaren
Implementationsstandes> aller unterstützten VRML-Browser.

Beispiele für VRML-Browser:

    Cosmo Player 1.0
    Cosmo Player 2.0
    Cosmo Player 2.1
    libcosmoplayer.so
    GLview
    Live3D 1.0
    Live3D 2.0
    VRweb
    WorldView 2.0 Plugin

Gebräuchliche HTML-Browser:

    Mozilla (Netscape)
    Mosaic
    MSIE (Microsoft Internet Explorer)

Prinzipiell ist es auch möglich über das API eines VRML-2.0-Browsers, den
Namen und die Version zu ermitteln. Dieses Verfahren besitzt jedoch einen
entscheidenden Nachteil: Bevor über das API die Informationen abgefragt
werden können, muß die Szenenquelle bereits erstellt und erfolgreich geladen
worden sein. Dann ist es aber für syntaktische Änderungen bereits zu spät.

Ein Beispiel für das unterschiedliche Verhalten der VRML-Browser ist die
Interpretation eines escapten doppelten Anführungszeichens innerhalb einer
Zeichenkette. Während einige Browser es, wie in der Spezifikation
beschrieben, darstellen können, beenden andere Browser die Zeichenkette
vorzeitig und erzeugen somit weitere Syntaxfehler. Ein weiteres Problem ist
die unterstützte Sprache im Script-Knoten. Hier muß bei einigen Browsern
'vrmlscript' angegeben werden.

Beispiel:

    $vrml->browser("Cosmo Player 2.0","Mozilla");

=item comment

F<comment('string')>

 string MFString []

fügt an der aktuellen Szenenposition einen Kommentar ein. Jeder Zeichenkette
aus dem Parameter I<string> wird ein Doppelkreuz vorangestellt und ein
Zeilenvorschub angefügt.

=item insert

F<insert('string')>

 string SFString ""

fügt vorhandenen VRML-Code in die Szene ein. Dieser kann als skalare Variable
oder als konstante Zeichenkette dem Parameter I<string> übergeben werden.

Beispiel:

    $vrml
    ->begin
      ->insert("Shape { geometry Box {} }")
    ->end
    ->print;

Befinden sich im vorhandenen VRML-Code doppelte Anführungszeichen, so sollte
die Perl-Funktion qq verwendet werden, um den Code unverändert übernehmen zu
können. Alternativ dazu besteht die Möglichkeit, die Anführungszeichen durch
einen Backslash zu maskieren (\" ).

    $vrml
    ->begin
      ->insert(qq(WorldInfo { title "Meine Welt" } ))
    ->end
    ->print;


Der Szenenaufbau kann schnell unübersichtlich werden, wenn der VRML-Code
einige Zeilen überschreitet. Für das Einfügen größerer Programmteile ist die
Methode C<insert__DATA__> besser geeignet.


=item insert__DATA__

F<insert__DATA__()>

macht sich die Perl-Syntax zu nutze, in der alle folgenden Zeilen nach der
Zeichenkette __DATA__ als Daten behandelt werden. Diese liest die Methode
F<insert__DATA__> ein und fügt sie an der betreffenden Stelle in die Szene
ein. Beachte die führenden und abschließenden ZWEI Unterstriche.

Beispiel:

    use VRML;
    new VRML(2)
    ->begin
      ->insert__DATA__
    ->end
    ->print;

    __DATA__
    Shape {
      geometry Sphere {}
      appearance Appearance {
	material Material {
	  diffuseColor 0 0.5 0
	}
      }
    }

B<Hinweis:> Der __DATA__-Abschnitt in Perl-Skripten wird derzeit nicht von
C<modperl> auf dem Apache-Server unterstützt. D.h. F<insert__DATA__>
funktioniert dort nicht wie erwartet.

=item include

F<include('files')>

 files MFString []

fügt vorhandene VRML-Dateien in die aktuelle Szene ein. Der Parameter
I<files> kann eine Liste von Dateinamen enthalten, die der Reihenfolge nach
eingebunden werden.

Beispiel:

    $vrml->include("c:/vrml/cubes.wrl");

=item print

F<print('mime', 'pipe')>

 mime SFBool   0
 pipe SFString ""

übergibt den Inhalt des Szenenobjekts an STDOUT. Das bedeutet im Normalfall,
daß die VRML-Quelle auf dem Bildschirm erscheint. Wird das Skript von einem
WWW-Server über CGI gestartet, so benötigt der Client (Browser) einen
MIME-Typ, um die korrekte Wiedergabeart zu ermitteln. Der MIME-Typ muß im
Header vor der eigentlichen Szene gesendet werden. Über den Parameter I<mime>
kann diese Option aktiviert werden.

Um die Übertragungs- bzw. Ladezeiten virtueller Welten zu verkürzen, besteht
die Möglichkeit, VRML-Quellen zu komprimieren. Zu diesem Zweck wird ein
Programm benötigt, welches das GNU-ZIP-Verfahren realisiert. Über den
Parameter pipe müssen der Pfad, Name und die Programmparameter der
ausführbaren Datei spezifiziert werden. Befindet sich die Datei im aktuellen
Pfad, genügt nur der Name und die Parameter (meistens C<gzip -f>). Der
Parameter I<pipe> ist jedoch nicht nur auf das Komprimieren der VRML-Skripte
beschränkt. Prinzipiell kann hier jeder Filter angewendet werden.

Beispiel 1:

    $vrml->print;


Beispiel 2 (UNIX gzip):

    $vrml->print(1,"/usr/local/bin/gzip -f");


Beispiel 3 (MS-DOS gzip.exe):

    $vrml->print(1,"c:\\Perl\\bin\\gzip.exe -f");


oder für alle Plattformen, wenn sich das Programm C<gzip> im Suchpfad
befindet:

    $vrml->print(1,"gzip -f");


=item save

F<save('filename', 'pipe')>

 filename SFString ""
 pipe     SFString ""

speichert den Inhalt des Szenenobjekts in einer Datei. Wird kein Dateiname
angegeben, so wird die Erweiterung des gerade abgearbeiteten Skripts (z. B.
.pl) gegen die Erweiterung '.wrl' ausgetauscht. Um bei großen Welten
Speicherplatz zu sparen, besteht auch hier die Möglichkeit, die VRML-Datei zu
komprimieren. Zu diesem Zweck wird ein Programm benötigt, das ein beliebiges
Pack-Verfahren realisiert. Besonders gut eignet sich dafür das
GNU-ZIP-Verfahren, da es vom VRML-Browser selbst entpackt werden kann. Über
den Parameter I<pipe> muß der Name und Pfad der ausführbaren Datei
spezifiziert werden. Die Funktionsweise von I<pipe> ist analog der in der
Methodenbeschreibung von C<print>.

Beispiel 1:

    $vrml->save;


Beispiel 2:

    $vrml->save("world.wrl");


Beispiel 3:

    $vrml->save(undef,"gzip");


=item as_string

F<as_string()>

gibt die komplette VRML-Quelle als Zeichenkette zurück. Sie wird jedoch nur
in seltenen Fällen benötigt und ist die einzige Methode, welche nicht eine
Referenz auf das Szenenobjekt zurückliefert. Für die Ausgabe oder Speicherung
einer VRML-Quelle sollten im allgemeinen die Methoden C<print> oder C<save>
benutzt werden. Diese Methoden sind wesentlich effizienter und schonen die
Ressourcen des Rechners.

    $vrml
    ->begin
      ->box("1 2 1")
    ->end;
    $scene = $vrml->as_string;



=back

Folgende Methoden sollten nicht verwendet werden. Sie sind normalerweise
nicht notwendig. Besteht dennoch Bedarf, so sende mir bitte eine E-Mail und
ich werde sie in den nächsten Versionen beschreiben.

=over 4

=item debug

=item _init

=item _add

=item _trim

=item _swap

=item _put

=item _row

=item _pos

=back

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

=cut

