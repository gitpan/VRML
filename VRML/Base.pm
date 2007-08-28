package VRML::Base;

############################## Copyright ##############################
#                                                                     #
# This program is Copyright 1996,1998 by Hartmut Palm.                #
# This program is free software; you can redistribute it and/or       #
# modify it under the terms of the GNU General Public License         #
# as published by the Free Software Foundation; either version 2      #
# of the License, or (at your option) any later version.              #
#                                                                     #
# This program is distributed in the hope that it will be useful,     #
# but WITHOUT ANY WARRANTY; without even the implied warranty of      #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       #
# GNU General Public License for more details.                        #
#                                                                     #
# If you do not have a copy of the GNU General Public License write   #
# to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge,     #
# MA 02139, USA.                                                      #
#                                                                     #
#######################################################################

require 5.000;
use strict;
use vars qw($VERSION $PI $PI_2);

$VERSION = "1.07de";
$PI = 3.1415926;
$PI_2 = $PI/2;

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
    $self->_put("# Set Browser to: '$self->{'browser'}'\n")
      if $self->{'DEBUG'};
    return $self;
}

#####################################################################
#               Methods to modify the VRML array
#
#####################################################################

sub _init {
    my $self = shift;
    my $vrml = shift;
    $self->{'VRML'} = [$vrml];
    return $self;
}

sub _add {
    my $self = shift;
    my $vrml = shift;
    ${$self->{'VRML'}}[$#{$self->{'VRML'}}] .= $vrml;
    return $self;
}

sub _put {
    my $self = shift;
    my $vrml = shift;
    push @{$self->{'VRML'}}, $vrml;
    return $self;
}

sub _row {
    my $self = shift;
    my ($row) = @_;
    my $vrml = $self->{'TAB'}.$row;
    push @{$self->{'VRML'}}, $vrml;
    return $self;
}

sub _swap {
    my $self = shift;
    my $element1 = pop @{$self->{'VRML'}};
    my $element2 = pop @{$self->{'VRML'}};
    push @{$self->{'VRML'}}, $element1;
    push @{$self->{'VRML'}}, $element2;
    return $self;
}

sub _pos {
    my $self = shift;
    return $#{$self->{'VRML'}};
}

sub _trim {
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
    $self->_put("# Set Debug Level to: $self->{'DEBUG'}\n");
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

sub string_to_array  {
    my $self = shift;
    my $pt = shift;
    return @$pt if ref $pt eq 'ARRAY';
    # remove leading/trailing spaces!
    my $tmp = $pt; $tmp =~ s/^\s+//; $tmp =~ s/\s+$//;
    return split(/\s+/,$tmp);
}

#--------------------------------------------------------------------
#       Insert Comments
#--------------------------------------------------------------------
sub comment {
    my $self = shift;
    my ($comment) = @_;
    $comment = defined $comment ? "# ".$comment : "#";
    push @{$self->{'VRML'}}, $comment."\n";
    return $self;
}

#--------------------------------------------------------------------
#       In-/Output VRML
#--------------------------------------------------------------------
sub insert {
    my $self = shift;
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    $string = $self->{'TAB'}.$string;
    $string =~ s/\n/\n$self->{'TAB'}/g;
    push @{$self->{'VRML'}}, $string."\n";
    return $self;
}

sub insert__DATA__ {
    my $self = shift;
    $self->{'DATApos'} = tell(main::DATA) unless defined $self->{'DATApos'};
    print "     self->{'DATApos'}=$self->{'DATApos'}\n" if $self->{'DEBUG'};
    push @{$self->{'VRML'}}, <main::DATA>,"\n";
    seek(main::DATA,$self->{'DATApos'},0);
    return $self;
}

sub include {
    my $self = shift;
    my @filename = @_;
    return $self if !defined $filename[0] || $filename[0] eq "";
    foreach (@filename) {
        open(INCLUDE, "<$_") || die "Can't include \"$_\"\n$!\n";
        push @{$self->{'VRML'}}, <INCLUDE>;
        push @{$self->{'VRML'}}, "\n";
        close(INCLUDE);
    }
    return $self;
}

sub format {
    my $self = shift;
    my $format = shift;
    if (defined $format && $format eq "none") {
        map { s/^[\t ]+//; s/\n[\t ]+/\n/g; s/\t+/ /g; s/ +/ /g; } @{$self->{'VRML'}};
    } else {
        map { s/    / /g; s/\t/  /g; } @{$self->{'VRML'}};
    }
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
    local $_ = undef;
    foreach (@_) {
        s/[\204\344\365]/ae/g;
        s/[\224\366]/oe/g;
        s/[\201\374]/ue/g;
        s/[\216\304]/Ae/g;
        s/[\231\305\326]/Oe/g;
        s/[\263\334]/Ue/g;
        s/[\257\337]/sz/g;
        s/[\000-\010\013-\037\177-\377]/_/g;
    }
    return (@_) if wantarray;
    return $_[0];
}

sub utf8 {
    my $self = shift;
    local $_ = undef;
    #foreach (@_) {
    #    s/[\201\374]/\x00\x75\x03\x08/g;
    #    s/(.)/\x00$1/g;
    #}
    return (@_) if wantarray;
    return $_[0];
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

VRML::Base.pm - Basis-Methoden fuer die VRML 1 und 2 Module

=head1 SYNOPSIS

    use VRML::Base;

=head1 DESCRIPTION

Folgende Methoden stehen zur Verfuegung.

=over 4

=item new

F<new>

erzeugt ein neues VRML-Szenen-Objekt. Diese Methode muss vor der Verwendung
einer weiteren Methode aufgerufen werden.

=item browser

F<browser("vrml", "html")>

 vrml SFString ""
 html SFString ""


Die Implementierung der VRML-Spezifikationen in den Browsern und Plug-ins ist
je nach Entwicklungsstand und Hersteller unterschiedlich. Um einige
allgemeine Besonderheiten beruecksichtigen zu koennen und Anzeigefehler zu
verhindern, sollte deshalb der F<browser>-Methode der Name des VRML- und
HTML-Browsers mitgegeben werden. I<Leere Parameter> oder das Weglassen der
Methode bewirken die Verwendung des I<kleinsten vertretbaren
Implementationsstandes> aller unterstuetzten VRML-Browser.

Beispiele fuer VRML-Browser:

    Cosmo Player 1.0
    Cosmo Player 2.0
    Cosmo Player 2.1
    libcosmoplayer.so
    GLview
    Live3D 1.0
    Live3D 2.0
    VRweb
    WorldView 2.0 Plugin

Gebraeuchliche HTML-Browser:

    Mozilla (Netscape)
    Mosaic
    MSIE (Microsoft Internet Explorer)

Prinzipiell ist es auch moeglich ueber das API eines VRML-2.0-Browsers, den
Namen und die Version zu ermitteln. Dieses Verfahren besitzt jedoch einen
entscheidenden Nachteil: Bevor ueber das API die Informationen abgefragt
werden koennen, muss die Szenenquelle bereits erstellt und erfolgreich geladen
worden sein. Dann ist es aber fuer syntaktische Aenderungen bereits zu spaet.

Ein Beispiel fuer das unterschiedliche Verhalten der VRML-Browser ist die
Interpretation eines escapten doppelten Anfuehrungszeichens innerhalb einer
Zeichenkette. Waehrend einige Browser es, wie in der Spezifikation
beschrieben, darstellen koennen, beenden andere Browser die Zeichenkette
vorzeitig und erzeugen somit weitere Syntaxfehler. Ein weiteres Problem ist
die unterstuetzte Sprache im Script-Knoten. Hier muss bei einigen Browsern
'vrmlscript' angegeben werden.

Beispiel:

    $vrml->browser("Cosmo Player 2.0","Mozilla");

=item comment

F<comment('string')>

 string MFString []

fuegt an der aktuellen Szenenposition einen Kommentar ein. Jeder Zeichenkette
aus dem Parameter I<string> wird ein Doppelkreuz vorangestellt und ein
Zeilenvorschub angefuegt.

=item insert

F<insert('string')>

 string SFString ""

fuegt vorhandenen VRML-Code in die Szene ein. Dieser kann als skalare Variable
oder als konstante Zeichenkette dem Parameter I<string> uebergeben werden.

Beispiel:

    $vrml
    ->begin
      ->insert("Shape { geometry Box {} }")
    ->end
    ->print;

Befinden sich im vorhandenen VRML-Code doppelte Anfuehrungszeichen, so sollte
die Perl-Funktion qq verwendet werden, um den Code unveraendert uebernehmen zu
koennen. Alternativ dazu besteht die Moeglichkeit, die Anfuehrungszeichen durch
einen Backslash zu maskieren (\" ).

    $vrml
    ->begin
      ->insert(qq(WorldInfo { title "Meine Welt" } ))
    ->end
    ->print;


Der Szenenaufbau kann schnell unuebersichtlich werden, wenn der VRML-Code
einige Zeilen ueberschreitet. Fuer das Einfuegen groesserer Programmteile ist die
Methode C<insert__DATA__> besser geeignet.


=item insert__DATA__

F<insert__DATA__()>

macht sich die Perl-Syntax zu nutze, in der alle folgenden Zeilen nach der
Zeichenkette __DATA__ als Daten behandelt werden. Diese liest die Methode
F<insert__DATA__> ein und fuegt sie an der betreffenden Stelle in die Szene
ein. Beachte die fuehrenden und abschliessenden ZWEI Unterstriche.

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
C<modperl> auf dem Apache-Server unterstuetzt. D.h. F<insert__DATA__>
funktioniert dort nicht wie erwartet.

=item include

F<include('files')>

 files MFString []

fuegt vorhandene VRML-Dateien in die aktuelle Szene ein. Der Parameter
I<files> kann eine Liste von Dateinamen enthalten, die der Reihenfolge nach
eingebunden werden.

Beispiel:

    $vrml->include("c:/vrml/cubes.wrl");

=item print

F<print('mime', 'pipe')>

 mime SFBool   0
 pipe SFString ""

uebergibt den Inhalt des Szenenobjekts an STDOUT. Das bedeutet im Normalfall,
dass die VRML-Quelle auf dem Bildschirm erscheint. Wird das Skript von einem
WWW-Server ueber CGI gestartet, so benoetigt der Client (Browser) einen
MIME-Typ, um die korrekte Wiedergabeart zu ermitteln. Der MIME-Typ muss im
Header vor der eigentlichen Szene gesendet werden. Ueber den Parameter I<mime>
kann diese Option aktiviert werden.

Um die Uebertragungs- bzw. Ladezeiten virtueller Welten zu verkuerzen, besteht
die Moeglichkeit, VRML-Quellen zu komprimieren. Zu diesem Zweck wird ein
Programm benoetigt, welches das GNU-ZIP-Verfahren realisiert. Ueber den
Parameter pipe muessen der Pfad, Name und die Programmparameter der
ausfuehrbaren Datei spezifiziert werden. Befindet sich die Datei im aktuellen
Pfad, genuegt nur der Name und die Parameter (meistens C<gzip -f>). Der
Parameter I<pipe> ist jedoch nicht nur auf das Komprimieren der VRML-Skripte
beschraenkt. Prinzipiell kann hier jeder Filter angewendet werden.

Beispiel 1:

    $vrml->print;


Beispiel 2 (UNIX gzip):

    $vrml->print(1,"/usr/local/bin/gzip -f");


Beispiel 3 (MS-DOS gzip.exe):

    $vrml->print(1,"c:\\Perl\\bin\\gzip.exe -f");


oder fuer alle Plattformen, wenn sich das Programm C<gzip> im Suchpfad
befindet:

    $vrml->print(1,"gzip -f");


=item save

F<save('filename', 'pipe')>

 filename SFString ""
 pipe     SFString ""

speichert den Inhalt des Szenenobjekts in einer Datei. Wird kein Dateiname
angegeben, so wird die Erweiterung des gerade abgearbeiteten Skripts (z. B.
.pl) gegen die Erweiterung '.wrl' ausgetauscht. Um bei grossen Welten
Speicherplatz zu sparen, besteht auch hier die Moeglichkeit, die VRML-Datei zu
komprimieren. Zu diesem Zweck wird ein Programm benoetigt, das ein beliebiges
Pack-Verfahren realisiert. Besonders gut eignet sich dafuer das
GNU-ZIP-Verfahren, da es vom VRML-Browser selbst entpackt werden kann. Ueber
den Parameter I<pipe> muss der Name und Pfad der ausfuehrbaren Datei
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

gibt die komplette VRML-Quelle als Zeichenkette zurueck. Sie wird jedoch nur
in seltenen Faellen benoetigt und ist die einzige Methode, welche nicht eine
Referenz auf das Szenenobjekt zurueckliefert. Fuer die Ausgabe oder Speicherung
einer VRML-Quelle sollten im allgemeinen die Methoden C<print> oder C<save>
benutzt werden. Diese Methoden sind wesentlich effizienter und schonen die
Ressourcen des Rechners.

    $vrml
    ->begin
      ->box("1 2 1")
    ->end;
    $scene = $vrml->as_string;


=item ascii

F<ascii('string')>

transformiert alle Umlaute in ae, oe, ue und sz. Weiterhin enfernt die Methode
alle Steuerzeichen.

    $vrml->text($vrml->ascii("umlaute"), ' yellow')


=back

Folgende Methoden sollten nicht verwendet werden. Sie sind normalerweise
nicht notwendig. Besteht dennoch Bedarf, so sende mir bitte eine E-Mail und
ich werde sie in den naechsten Versionen beschreiben.

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

