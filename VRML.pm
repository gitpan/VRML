package VRML;

############################## Copyright ##############################
#								      #
# This program is Copyright 1996,1998 by Hartmut Palm.		      #
# This program is free software; you can redistribute it and/or	      #
# modify it under the terms of the GNU General Public License	      #
# as published by the Free Software Foundation; either version 2      #
# of the License, or (at your option) any later version.	      #
# 								      #
# This program is distributed in the hope that it will be useful,     #
# but WITHOUT ANY WARRANTY; without even the implied warranty of      #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	      #
# GNU General Public License for more details.			      #
# 								      #
# If you do not have a copy of the GNU General Public License write   #
# to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge,     #
# MA 02139, USA.						      #
#								      #
#######################################################################

require 5.000;
use strict;
use vars qw(@ISA $VERSION);
$VERSION="1.04de";

sub new {
    my $class = shift;
    my ($version) = @_ ? @_ : 0;
    my $self;
    if ( $version == 2 || $version == 97 ) {
	require VRML::VRML2;
	@ISA = qw(VRML::VRML2);
	$self = new VRML::VRML2;
    } elsif ( $version == 1 ) {
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

VRML - spezfikationsunabhängige VRML-Methoden (1.0, 2.0, 97)

=head1 SYNOPSIS

  use VRML;

  $vrml = new VRML(2);
  $vrml->browser('Cosmo Player 2.0','Netscape');
  $vrml->at('-15 0 20');
  $vrml->box('5 3 1','yellow');
  $vrml->back;
  $vrml->print;
  $vrml->save;

  ODER mit dem gleichen Ergebnis

  use VRML;

  VRML->new(2)
  ->browser('Cosmo Player 2.0','Netscape')
  ->at('-15 0 20')->box('5 3 1','yellow')->back
  ->print->save;

=head1 DESCRIPTION

Diese Module wurden für die Erzeugung von VRML auf WWW-Servern über die
CGI-Schnittestelle und/oder zum Generieren abstrakter Welten konzipiert. Sie
sollen die Übersichtlichkeit von Perl-Skripten mit VRML-Code erhöhen und
(hoffentlich) VRML-Anfängern den Einstieg in VRML erleichtern.
Im folgenden werden die Module kurz beschrieben.

=over 4

=item VRML::Base

enthält die Basisfunktionalität wie Erzeugen, Ausgeben und Speichern. Es
stellt die Basisklasse für alle anderen Module dar.

=item VRML::VRML1

faßt mehrere VRML 1.0 Knoten zu komplexen Methoden zusammen - wie z.B.
geometrische Körper inklusive Material. Dieses Modul akzeptiert Winkelangaben
in Grad und als Material Farbnamen. Die Methoden haben die gleichen Namen wie
in der VRML-Spezifikation (sofern sinnvoll), werden jedoch
F<kleingeschrieben>.

=item VRML::VRML1::Standard

realisiert nur die VRML 1.0 Knoten. Alle Methodennamen sind identisch (in der
Schreibweise) mit denen der VRML-Spezifikation. Die Parameter sind nach der
Häufigkeit ihrer Verwendung angeordnet. (subjektive Einschätzung)

Dieses Modul fällt möglicherweise in der nächsten Version weg. Die Erzeugung
der VRML-Knoten übernimmt dann VRML::Base.

=item VRML::VRML2

faßt mehrere VRML 2.0 Knoten zu komplexen Methoden zusammen - wie z.B.
geometrische Körper inklusive Material. Dieses Modul akzeptiert Winkelangaben
in Grad und als Material Farbnamen. Die Methoden haben die gleichen Namen wie
in der VRML-Spezifikation (sofern sinnvoll), werden jedoch
F<kleingeschrieben>. Die Namen sind auch weitestgehend identisch mit denen
des Moduls VRML::VRML1. Dadurch kann der Nutzer zwischen den zu erzeugenden
VRML-Versionen umschalten.

Enthält beispielsweise C<$in{VRML}> '1' oder '2' (z.B. über CGI), so muß
nur die folgende Zeile am Anfang des Perl-Skripts eingefügt werden.

    new VRML($in{'VRML'})

=item VRML::VRML2::Standard

realisiert nur die VRML 2.0 Knoten. Alle Methodennamen sind identisch (in der
Schreibweise) mit denen der VRML-Spezifikation. Die Parameter sind nach der
Häufigkeit ihrer Verwendung angeordnet. (subjektive Einschätzung)

Dieses Modul fällt möglicherweise in der nächsten Version weg. Die Erzeugung
der VRML-Knoten übernimmt dann VRML::Base.

=item VRML::Color

enthält die Farbnamen und Konvertierungsfunktionen.

=back

Die VRML-Methoden sind derzeit identisch in den Modulen VRML::VRML1.pm
und VRML::VRML2.pm implementiert. Die Basis-Methoden wie C<new>, C<print>
oder C<save> sind im Modul VRML::Base beschrieben.

=head2 Gruppen

=over 4

=item begin

F<begin('comment')>

Die Methoden B<begin> und B<end> stellen die äußere Klammer der VRML-Szene
dar. Die Methode B<begin> führt einige Initialisierungen und die Methode
B<end> abschließende Berechnungen durch. Jedes VRML-Skript sollte stets nach
dem Erzeugen des Szenenobjekts ein B<begin> aufrufen und vor dem Ausgeben
bzw. Speichern die Methode B<end> ausführen.

Beispiel:

    new VRML
    ->begin
      ->at('0 0.1 -0.3')
	->sphere(1,'red')
      ->back
    ->end
    ->print;

=item end

F<end('comment')>

Diese Methode beendet die Ausdehnungs- und Viewpoint-Berechnungen. Nach
B<end> sollte keine Geometrie positioniert oder Transformation durchgeführt
werden.

=item anchor_begin

F<anchor_begin('url', 'description', 'parameter', 'bboxSize', 'bboxCenter')>

 url         MFString []
 description SFString ""
 parameter   MFString []
 bboxSize    SFVec3f  undef
 bboxCenter  SFVec3f  '0 0 0'

Die Methoden B<anchor_begin> und B<anchor_end> umschließen eine Gruppe von
Objekten, die wie ein Hyperlink arbeitet. Diese lädt den Inhalt einer URL,
sobald der Betrachter die Geometrien, die diese Methode enthält, aktiviert
(z. B. anklickt). Wenn die URL auf eine gültige VRML-Datei zeigt, wird die
aktuelle Szene durch eine neue ersetzt (ausgenommen der I<parameter>-Parameter
wird wie unten beschrieben eingesetzt). Werden Nicht-VRML-Daten empfangen, so
sollte der Browser ermitteln, wie diese Daten zu behandeln sind;
üblicherweise werden sie an einen entsprechenden Nicht-VRML-Browser
weitergereicht.

Eine Anchor-Methode mit einem leeren I<url>-Parameter führt keine Aktion aus,
auch wenn ihr Geometrieinhalt aktiviert wird.

Der I<description>-Parameter in der Anchor-Methode spezifiziert eine sprachliche
Beschreibung dieser Methode. Sie kann durch ein Browser-spezifisches
Benutzer-Interface verwendet werden, um zusätzliche Informationen zum Anchor
zu liefern.

Der I<parameter>-Parameter kann auch eingesetzt werden, um dem VRML- oder
HTML-Browser zusätzliche Informationen zu übermitteln. Jede Zeichenkette
muß den Aufbau Schlüssel=Wert besitzen. Beispielsweise, erlauben einige
Browser die Angabe eines 'target' für einen Link, um ihn in einem anderen Teil
des HTML-Dokuments zu laden. Der I<parameter>-Parameter lautet dann:

    $vrml
    ->anchor_begin('http://www.yourdomain.de', 'Neue Seite',
      'target=name_des_frames')
      ->cylinder('2 4','red')
    ->anchor_end

Die Methode B<anchor_begin> kann auch benutzt werden, um den Eingangs-Viewpoint
einer Welt zu bestimmen, indem ein auf #ViewpointName endender URL
spezifiziert wird. Dabei ist ViewpointName der Name eines Viewpoints einer
VRML-Szene.

Beispiel:

    $vrml
    ->anchor_begin('http://www.gfz-potsdam.de/~palm/vrml/index.wrl#Eingang')
      ->box('1 2 3','green')
    ->anchor_end

Wird der obige Quader aktiviert, so lädt dieser die Datei C<index.wrl> und
positioniert den Betrachter auf einen Viewpoint mit dem Namen Eingang. Ist
der benannte Viewpoint nicht vorhanden, dann wird der Standard-Viewpoint der
Szene verwendet.

Wenn der I<url>-Parameter nur den #ViewpointName enthält (d. h. ohne
Dateinamen), wird der Viewpoint mit dem Namen ViewpointName in der aktuellen
Welt eingestellt. Zum Beispiel binden die folgenden Programmzeilen:

    $vrml
    ->anchor_begin('#Start')
      ->sphere(1,'blue')
    ->anchor_end


den Browser an die Kameraposition, die durch den Viewpoint Start in der
aktuellen Welt definiert ist, sobald die Kugel aktiviert wird. Im Fall, daß
der Viewpoint nicht gefunden werden kann, führt der Browser keine Aktion aus.

Die I<bboxCenter>- und I<bboxSize>-Parameter spezifizieren ein Begrenzungsvolumen,
der alle anchor-Kinder einschließt. Diese Information ist für den Browser nur
ein Hinweis und kann von ihm für Optimierungszwecke benutzt werden. Wenn das
spezifizierte Begrenzungsvolumen kleiner als das wirkliche Begrenzungsvolumen
der Kinder ist, kann das zu unerwünschten Ergebnissen führen. Der
Standardwert für I<bboxSize>, (-1 -1 -1), steht für ein undefiniertes
Begrenzungsvolumen. Wird es benötigt, so muß es vom Browser selbst berechnet
werden.

Das folgende Beispiel lädt die HTML-Startseite des VRML-Moduls in ein neues
Fenster:

    $vrml
    ->anchor_begin('http://www.gfz-potsdam.de/~palm/vrmlperl/',
      'VRML-Perl Module', 'target=_blank')
    ->sphere(1,'blue')
    ->anchor_end;

=item anchor_end

Beendet C<anchor_begin>.

=item billboard_begin

F<billboard_begin('axisOfRotation', 'bboxSize', 'bboxCenter')>

 axisOfRotation  SFVec3f  '0 1 0'
 bboxSize        SFVec3f  undef
 bboxCenter      SFVec3f  '0 0 0'

Die Methode B<billboard_begin> richtet das lokale Koordinatensystem so aus,
daß die z-Achse dem Betrachter zugewandt ist. Dadurch werden alle sichtbaren
Objekte gewissermaßen auf die Kamera ausgerichtet. Der
I<axisOfRotation>-Parameter spezifiziert, um welche Achse die Rotation
ausgeführt werden soll. Diese Achse befindet sich innerhalb des lokalen
Koordinatensystems.

Ein Spezialfall ist die vollständige Betrachterausrichtung. In diesem Fall
wird die lokale y-Achse des Objekts mit der des Betrachters parallel
gehalten. Das läßt sich erreichen, indem man den Parameter I<axisOfRotation>
auf den Wert (0 0 0) setzt.

In einigen anderen Fällen kann es zu unerwarteten Ergebnissen kommen. Setzt
man zum Beispiel die I<axisOfRotation> auf (0 1 0), d. h. auf die y-Achse, und
der Betrachter fliegt über diese und schaut darauf, so entsteht ein
undefinierter Zustand.

Die I<bboxCenter>- und I<bboxSize>-Parameter spezifizieren ein
Begrenzungsvolumen, das alle Billboard-Kinder einschließt. Diese Information
ist für den Browser nur ein Hinweis und kann von ihm für Optimierungszwecke
benutzt werden. Wenn das spezifizierte Begrenzungsvolumen kleiner als das
wirkliche Begrenzungsvolumen der Kinder ist, kann das zu unerwünschten
Ergebnissen führen. Der Standardwert für I<bboxSize>, (-1 -1 -1), steht für ein
undefiniertes Begrenzungsvolumen. Wird es benötigt, so muß es vom Browser
selbst berechnet werden. Die Methode C<billboard_end> hebt die
Betrachterausrichtung wieder auf.

=item billboard_end

Beendet C<billboard_begin>.

=item collision_begin

F<collision_begin(collide, proxy, 'bboxSize', 'bboxCenter')>

 collide    SFBool  1
 proxy      SFNode  NULL
 bboxSize   SFVec3f undef
 bboxCenter SFVec3f '0 0 0'

Alle geometrischen Körper besitzen in VRML 2.0 grundsätzlich die Eigenschaft,
mit dem Betrachter zu kollidieren, sowie er einen bestimmten Abstand
unterschreitet. Diese Eigenschaft kann über den Parameter I<collide> beeinflußt
werden. Geometrische Strukturen, die sich innerhalb der Methoden
B<collision_begin> und B<collision_end> befinden, gelten als durchdringbar, wenn
collide auf 0 gesetzt wird. Die Methode kann auch bei besonders komplexen
Strukturen verwendet werden, um einen Vertreter (engl. Proxy) als
alternatives Objekt für die Kollisionsberechnung anzugeben, das eine
ähnliche, aber einfachere Struktur besitzt.

Beispiel:

    $vrml
    ->collision_begin(1, sub{$vrml->box('5 1 0.01')})
      ->text('undurchdringbar','yellow',1,'MIDDLE')
    ->collision_end

=item collision_end

Beendet C<collision_begin>.

=item group_begin('comment')

Die Methoden B<group_begin> und B<group_end> stellen die einfachste Form einer
Gruppierung dar. Sie bewirken keine zusätzlichen Aktivitäten außer der
Gruppierung und führen auch keine Transformationen aus.

Beispiel:

    $vrml
    ->group_begin
      ->sphere(1,'red')
    ->group_end

=item group_end

Beendet C<group_begin>.

=item lod_begin

F<lod_begin('range', 'center')>

 range  MFFloat []
 center SFVec3f '0 0 0'

Die Methoden B<lod_begin> und B<lod_end> gestatten es dem VRML-Browser, zwischen
unterschiedlich detaillierten und damit unterschiedlich aufwendigen
Strukturen umzuschalten. Die Reihenfolge der Kindmethoden beginnt mit der
komplexesten und endet mit der einfachsten. Die Entfernungen im Parameter
I<range> müssen aufsteigend sortiert sein und immer mindestens einen Wert
weniger besitzen als Kindmethoden vorhanden sind. Werden keine Parameter
angegeben, so kann der VRML-Browser unter Gesichtspunkten der Optimierung
auswählen, welche Kindstruktur er darstellt. Der Parameter I<center> bestimmt
den Punkt, der für die Berechnung der Entfernung vom Betrachter aus verwendet
wird.

Das folgende Beispiel bringt einen Text in der VRML-Szene unter, der nur bis
zu einer bestimmten Entfernung gut lesbar ist und darüber hinaus
verschwindet. Natürlich hängt die Lesbarkeit von der Schrift- und
Bildschirmgröße ab. Diese Beziehung kann man im Bedarfsfall mit Variablen
recht einfach realisieren. Die Methode B<lod_begin> enthält in diesem Beispiel
eine Entfernung und benötigt somit zwei Kinder.

    $vrml
    ->lod_begin('30')
      ->text('gut lesbar')
      ->group_begin->group_end # leere Gruppe
    ->lod_end

=item lod_end

Beendet C<lod_begin>.

=item switch_begin

F<switch_begin(whichChoice)>

 whichChoice SFInt32 -1

Die Methoden B<switch_begin> und B<switch_end> umschließen mehrere Kinder,
von denen über den Parameter I<whichChoice> jeweils nur einer oder keiner
wiedergegeben wird. Alle Kinder sind mit 0 beginnend durchnumeriert und
können über ihren Index ausgewählt werden. Ist der Wert kleiner als 0 oder
größer als die Anzahl der zur Verfügung stehenden Kinder, so erfolgt keine
Wiedergabe. In VRML 1.0 wird dieses Verfahren hauptsächlich zum Umschalten
der Kameras und zur Definition von noch nicht benötigten Knoten eingesetzt.

=item switch_end

Beendet C<switch_begin>.

=item transform_begin

F<transform_begin(transformationsListe)>

 transformationsListe  SFString ""

Die wichtigste und mächtigste Methode zum Gruppieren stellt B<transform_begin>
dar. Sie bietet die Möglichkeit Translationen (Verschiebungen), Rotationen
(Drehungen) und Skalierungen (Vergrößerungen bzw. Verkleinerungen)
durchzuführen. Dabei wird ein lokales Koordinatensystem relativ zum
übergeordneten Koordinatensystem definiert. Alle durchgeführten
Transformationen werden in dem lokalen Koordinatensystem ausgeführt. Um alle
Transformationen zu beenden und zum übergeordneten Koordinatensystem
zurückzukehren, muß die Methode C<transform_end> aufgerufen werden. Sie benötigt
keinen Parameter.

Die I<transformationsListe> hat folgenden Aufbau:

    'Param1=Wert1', 'Param2=Wert2', ...

Param* kann die Anfangsbuchstaben der folgenden Wort belegen. Die
Kompatibilität zu VRML 1.0 ist nur bei Verwendung der Anfangsbuchstaben
gewährleistet.

=over 4

=item t = translation (Verschiebung)

Das lokale Koordinatensystem wird um die entsprechenden Anteile in x-, y- und
z-Richtung relativ zum übergeordneten Koordinatensystem verschoben.

=item r = rotation (Drehung)

Die Drehung wird um die angegebenen Achsen mit dem entsprechenden Winkel
durchgeführt. Das Rotationszentrum kann über den Parameter c (I<center>)
angegeben werden.

=item s = scale bzw. scaleFactor in VRML 1.0 (Vergrößerungsvektor bzw.
Vergrößerungsfaktor)

Gibt für jede Richtung einen Skalierungsfaktor an. Die neuen Koordinaten
werden bezüglich des Punktes im Parameter c (I<center>) berechnet.

=item so = scaleOrientation (Skalierungsrichtung)

Dient zur Angabe einer Drehung, die sich nur bei der Skalierung auswirkt.

=item c = center (Zentrum)

Der Vektor wird als Verschiebung relativ zum lokalen Koordinatensystem
angegeben; er wird bei einer Skalierung oder Rotation als Ursprung benutzt.

=back

Wert* beinhaltet eine Zeichenkette des entsprechenden Typs.

Beispiel:

    $vrml
    ->transform_begin('t=0 1 0','r=180')
      ->cone('0.5 2','red')
    ->transform_end

=item transform_end

Beendet C<transform_begin>.

=item at

Die Methode B<at> bzw. die Methode C<back> sind verkürzte Schreibweisen für
C<transform_begin> bzw. C<transform_end>. Da diese Methoden am häufigsten benötigt
werden, läßt sich mit der verkürzten Schreibweise eine bessere Lesbarkeit
erreichen.

Beispiel:

    $vrml
    ->at('0 2 0')
      ->sphere(0.5,'red')
    ->back

=item back

ist die Kurzversion von C<transform_end>.

=item inline

F<inline('url', 'bboxSize', 'bboxCenter')>

 url        MFString []
 bboxSize   SFVec3f  undef
 bboxCenter SFVec3f  '0 0 0'

Die Methode B<inline> kommt ohne _begin und _end aus, da ihre Kinder nur über
URLs eingebunden werden. Als zusätzliche Informationen können dem Browser
Angaben über Ausdehnung und Position der Szene in Form eines
Begrenzungsvolumens mitgeteilt werden. Da es sich aber möglicherweise um
Szenen eines anderen Servers handelt, bedarf es eines ausgeklügelten
Kontrollmechanismus', den der Anwender selbst implementieren muß, um externe
Änderungen in den lokalen bbox-Angaben nachzuführen.

=back

=head2 Unabhängige Methoden

=over 4

=item background

F<background(
frontUrl =E<gt> '...',
leftUrl =E<gt> '...',
rightUrl =E<gt> '...',
backUrl =E<gt> '...',
bottomUrl =E<gt> '...',
topUrl =E<gt> '...',
skyColor =E<gt> '...',
skyAngle =E<gt> '...',
groundColor =E<gt> '...',
groundAngle =E<gt> '...'
)>

 frontUrl    MFString []
 leftUrl     MFString []
 rightUrl    MFString []
 backUrl     MFString []
 bottomUrl   MFString []
 topUrl      MFString []
 skyColor    MFColor  ['0 0 0']
 skyAngle    MFFloat  []
 groundColor MFColor  []
 groundAngle MFFloat  []


Die B<background>-Methode kann sowohl zum Erzeugen eines farbigen Himmels und
Bodens, als auch einer Hintergrundtextur in Form eines Panoramas, das sich
hinter der gesamten Geometrie befindet, verwendet werden. Hintergrundmotive
werden in dem lokalen Koordinatensystem spezifiziert und nur durch Rotationen
beeinflußt.

Der I<skyColor>-Parameter spezifiziert die Farbe des Himmels in verschiedenen
Winkeln auf der Himmelskugel. Der erste Wert des I<skyColor>-Parameters gibt die
Farbe des Himmels bei 0 Grad an. Der I<skyAngle>-Parameter spezifiziert die
Winkel vom Zenit, in denen die konzentrischen Kreise verlaufen sollen. Der
Zenit der Kugel ist implizit definiert mit 0.0 Grad; der natürliche Horizont
liegt bei 90 Grad und der Fußpunkt bei 180 Grad. Der Parameter I<skyAngle> ist
für aufsteigende Werte im Bereich [0, 180] definiert. Es muß immer ein
I<skyColor>-Wert mehr angegeben werden als I<skyAngle>-Werte existieren. Der erste
Farbwert bestimmt die Farbe des Zenits und benötigt keinen I<skyAngle>-Wert. Ist
der letzte I<skyAngle>-Wert kleiner als 180, dann wird für die Farbe vom letzten
I<skyAngle> bis zum Fußpunkt der letzte I<skyColor>-Wert verwendet. Die
Himmelsfarbe wird zwischen den I<skyColor>-Werten linear interpoliert.

Der I<groundColor>-Parameter spezifiziert die Farbe des Bodens in verschiedenen
Winkeln auf der Untergrundhalbkugel. Der erste Wert des
I<groundColor>-Parameters bestimmt die Farbe des Fußpunktes. Der
I<groundAngle>-Parameter gibt die Winkel an, in denen die Farbe in
konzentrischen Kreisen verläuft. Der Fußpunkt ist implizit definiert mit 0.0
Radians. Der Parameter I<groundAngle> ist für aufsteigende Werte im Bereich
[0.0, p /2] definiert. Es muß immer ein I<groundColor>-Wert mehr angegeben
werden als I<groundAngle>-Werte existieren. Ist der letzte I<groundAngle>-Wert
kleiner als p /2, so wird die Region zwischen dem letzten I<groundAngle>-Wert
und dem Äquator unsichtbar. Die Untergrundfarbe wird linear interpoliert
zwischen den einzelnen I<groundColor>-Werten.

Die I<backUrl>-, I<bottomUrl>-, I<frontUrl>-, I<leftUrl>-, I<rightUrl>- und
I<topUrl>-Parameter spezifizieren einen Satz von Bildern, die ein
Hintergrundpanorama zwischen den Geometrien und den Hintergrundfarben
definieren. Das Panorama besteht aus sechs Bildern, von denen jedes auf eine
Seite eines übergroßen Würfels im lokalen Koordinatensystem projiziert wird.
Die Bilder werden individuell jeder Seite zugeordnet. Alpha-Werte in den
Panoramabildern (d. h. Zwei- oder Vier-Komponentenbilder) machen bestimmte
Regionen halb- oder transparent und ermöglichen das Durchscheinen der
I<groundColor>- und I<skyColor>-Farben. Oftmals werden auch die I<bottomUrl>-
und I<topUrl>-Bilder nicht angegeben, um den Himmel und Boden sichtbar zu
lassen. Alle gängigen VRML-Browser unterstützen bisher die Bildformate JPEG
und GIF. Hinzu kommt das Format PNG, welches ausdrücklich in der
Spezifikation VRML 2.0 empfohlen wird. Panoramabilder können eine Komponente
(Graustufen), zwei Komponenten (Graustufen mit Alphakanal), drei Komponenten
(RGB), oder vier Komponenten (RGB mit Alphakanal) besitzen.

Der Betrachter kann sich nicht den Bildern nähern; er kann sich jedoch
drehen, um das ganze Panorama zu erfassen.

Der Hintergrund wird nicht durch die C<fog>-Methode (Nebel) beeinflußt. Es ist
Aufgabe des Szenenautors, die Farben verblassen zu lassen und die Bilder
entsprechend zu ändern, wenn sich der Betrachter im Nebel befindet.

Für die Generierung von VRML 1.0 werden nur die Parameter I<frontUrl> und
I<skyColor> berücksichtigt. Durch die Vielzahl der Parameter wurde bei der
C<background>-Methode die Übergabeform Parameter => Wert (Hash) gewählt. Dabei
spielt die Reihenfolge der Parameter keine Rolle; nicht benötigte Parameter
können weggelassen werden.

Beispiel:

    $vrml->background(skyColor => 'lightblue',
                      frontUrl => 'http://www.yourdomain.de/bg/berge.gif');

=item backgroundcolor

F<backgroundcolor('skyColor', 'groundColor')>

 skyColor     SFColor  '0 0 0'
 groundColor  SFColor  '0 0 0'

Die B<backgroundcolor>-Methode stellt eine stark vereinfachte Variante der
C<background>-Methode dar. Sie spezifiziert nur die Hintergrundfarben einer
Szene. Bei der Generierung einer VRML-2.0-Quelle wird der Parameter
I<skyColor> für den Himmel und I<groundColor> für den Boden verwendet. Für
VRML-1.0-Quellen wird der zweite Parameter ignoriert.

Beispiel:

    $vrml->backgroundcolor('lightblue');

=item backgroundimage

F<backgroundimage('url')>

 url SFString ""

Über die Methode B<backgroundimage> kann das Hintergrundbild einer Szene
definiert werden. Dazu muß der Parameter I<url> eine Grafikdatei enthalten.
Die am häufigsten unterstützten Grafikformate sind GIF, JPEG und PNG. Neben
diesen stellen einige VRML-Browser auch das BMP-Format dar. Aus Gründen der
Kompatibilität zur UNIX- und Macintosh-Welt und wegen des übermäßigen
Platzbedarfs sollte dieses Format nicht einsetzt werden. Die Methode
B<backgroundimage> belegt den kompletten Hintergrund in VRML 1.0 und alle
sechs Panoramabilder in VRML 2.0 mit dem gleichen Bild. Für eine individuelle
Zuweisung jedes Panoramateils muß die Methode C<background> verwendet werden.

Beispiel:

    $vrml->backgroundimage('http://www.yourdomain.de/bg/sterne.gif');

=item title

F<title('string')>

 string SFString ""

Die Angabe eines Titels in der Methode B<title> hat keine Auswirkung auf die
darstellbare Szene. Sie kann lediglich vom Browser als Zusatzinformation
verwendet werden und wird häufig in dessen Titelleiste angezeigt.

Beispiel:

    $vrml->title('Meine virtuelle Welt');

=item info

F<info('string')>

 string MFString []


Mit der Methode B<info> können beliebige Informationen in einer VRML-Datei
untergebracht werden.

Beispiel:

    $vrml->info('letzte Änderung: 8.05.1997');

=item worldinfo

F<worldinfo('title', 'info')>

 title  SFString ""
 info   MFString []


Die Methode B<worldinfo> stellt Informationen über die aktuelle Szene zur
Verfügung. Diese Methode ist nur für Dokumentationszwecke gedacht und hat
keinen Einfluß auf die VRML-Welt. Im I<title>-Parameter kann der Name oder
Titel der Welt gespeichert werden, um ihn gegebenenfalls in der Titelleiste
zu präsentieren. Andere Informationen über die Welt wie Autor, Copyright oder
Nutzungshinweise können im I<info>-Parameter abgelegt werden. Die Methode
B<worldinfo> kombiniert die Methoden C<title> und C<info>.

Beispiel:

    $vrml->worldinfo('Sofies Welt', 'Jostein Gaarder');

=item navigationinfo

F<navigationinfo('type', speed, headlight, visibilityLimit, avatarSize)>

 type         MFEnum     ['WALK', 'ANY'] # ANY, WALK, FLY, EXAMINE, NONE
 speed        SFFloat    1.0
 headlight    SFBool     1
 visibilityLimit SFFloat 0.0
 avatarSize   MFFloat    [0.25, 1.6, 0.75]

Mit der Methode I<navigationinfo> können verschiedene Informationen für die
Steuerung des VRML-Browsers festgelegt werden. Diese Informationen
beschreiben Eigenschaften des Betrachters und die Art wie er durch die Szene
navigiert. Die Bewegungsart wird über den Parameter I<type> spezifiziert. Beim
Gehen (WALK) wirkt die Schwerkraft auf den Betrachter, die ihn auf den
Untergrund zieht. Dadurch wird es ihm auch möglich, einem Gelände zu folgen.
Das Gehen erfordert eine aufrechte Haltung (parallel zur y-Achse), die durch
den Browser realisiert wird. Das Fliegen (FLY) ähnelt dem Gehen, jedoch ohne
die Wirkung einer Schwerkraft. Sowohl beim Gehen als auch beim Fliegen ist
die Kollisionserkennung standardmäßig eingeschaltet. Der Mindestabstand
zwischen dem Betrachter und geometrischen Objekten der Szene kann über den
ersten Wert des Parameters I<avatarSize> eingestellt werden (voreingestellt sind
25 cm). Wird dieser unterschritten, kollidiert man. Der zweite Wert des
Parameters I<avatarSize> bestimmt die Blickhöhe des Betrachters
(voreingestellt sind 1,6 Meter). Besonders negativ machen sich
Höhenunterschiede zwischen der aktuellen Blickhöhe und vordefinierten
Aussichtspunkten (engl. Viewpoints) bemerkbar. Hierbei wird die Höhe
angepaßt, sowie man sich von der Stelle bewegt, was zu einer Auf- bzw.
Abwärtsbewegung führt. Der dritte Wert des Parameters I<avatarSize>
spezifiziert die Höhe eines Körpers den der Betrachter bei eingeschalteter
Schwerkraft noch überwinden kann (voreingestellt sind 75 cm).

Die Geschwindigkeit, mit der man sich in der Welt bewegt, spezifiziert der
Parameter I<speed>. Sie wird in Metern pro Sekunde angegeben und beträgt
standardmäßig 1,0 m/s (3,6 km/h). Von den Parametern der aktuellen
Transformation beeinflußt nur der Skalierungsfaktor die Geschwindigkeit.

Viele VRML-Browser besitzen als zusätzliche Beleuchtung eine Helmlampe, deren
Lichtstrahlen in Blickrichtung verlaufen. Die Helmlampe ist je nach Browser
standardmäßig ein- oder ausgeschaltet. Erst in der Spezifikation VRML 2.0
wurde festgelegt, daß diese beim Start leuchtet, wenn sie nicht explizit
durch den Parameter I<headlight> ausgeschaltet wurde. Nach dem Laden der Szene
hat der Betrachter die Möglichkeit, den aktuellen Zustand zu ändern.

Die Sichtweite des Betrachters kann über den Parameter I<visibilityLimit>
eingegrenzt werden. Abhängig vom jeweiligen Browser brechen einige die
Darstellung an dieser Position ab, während andere nur komplette Geometrien
weglassen.

Beispiel:

    $vrml->navigationinfo('WALK', 1.5, 0, 1000);

=item viewpoint_begin

Kameradefinitionen bzw. Aussichtspunkte stehen üblicherweise im vorderen Teil
einer VRML-Quelle. Da sie aber - bei einer dynamischen Erstellung einer
VRML-Szene - erst in bestimmten Programmteilen berechnet werden können, gibt
es die Möglichkeit, die gewünschte Stelle mit der Methode B<viewpoint_begin> zu
markieren. Beim Aufruf der Methode C<viewpoint_end> werden die Definitionen an
der markierten Stelle eingefügt. Während in VRML 2.0 die Aussichtspunkte
prinzipiell über die ganze Quelle verstreut sein dürfen, müssen sich die
Camera-Knoten in VRML 1.0 innerhalb eines Switch-Knotens befinden. Nur dann
kann später zwischen ihnen gewechselt werden.

=item viewpoint

F<viewpoint('description', 'position', 'orientation', fieldOfView, jump)>

 description SFString          ""
 position    SFVec3f           0 0 10
 orientation SFRotation/SFEnum 0 0 1 0 # FRONT, LEFT, BACK, RIGHT, TOP, BOTTOM
 fieldOfView SFFloat           45 # Grad
 jump        SFBool            1

Die Methode B<viewpoint> dient der individuellen Positionierung einer Kamera
bzw. der Festlegung von bestimmten Aussichtspunkten. Der Parameter
I<position> spezifiziert die Position, an der sich die Kamera befinden soll.
Für den Parameter I<orientation> stehen neben der Angabe eines
SFRotation-Werts auch Synonyme für die häufigsten Richtungen FRONT, LEFT,
BACK, RIGHT, TOP, BOTTOM und ALL in Form von Zeichenketten zur Verfügung. Der
Parameter I<description> enthält die Bezeichnung des Aussichtspunktes. Er
wird später vom VRML-Browser in einem Pulldown-Menü dargestellt und zur
Auswahl angeboten. Nach jedem Hinzufügen eines neuen Aussichtspunktes wird
dieser als aktuelle Benutzersicht übernommen. Um das zu verhindern, muß der
Parameter I<jump> auf 0 gesetzt werden. Den Blickwinkel bestimmt der
Parameter I<fieldOfView>. Kleine Winkel sind vergleichbar mit einem
Teleobjektiv, große mit einem Weitwinkelobjektiv.

Beispiel:

    $vrml->viewpoint('Start','0 0 0','0 0 -1 0',60);

ist identisch mit

    $vrml->viewpoint('Start',undef,'FRONT',60);


=item viewpoint_set

F<viewpoint_set('center', distance, fieldOfView, avatarSize)>

 center       SFVec3f '0 0 0'
 distance     SFFloat 10
 fieldOfView  SFFloat 45 # Grad
 avatarSize   MFFloat [0.25, 1.6, 0.75]

Eine zeitraubende und ständig wiederkehrende Arbeit ist die Positionierung
von Aussichtspunkten (engl. Viewpoints) für die Standardansichten von vorn,
von rechts, von hinten, von links, von oben und von unten. Die Methode
B<viewpoint_set> soll helfen, diese undankbare Aufgabe zu erleichtern. Durch
ihre Anwendung lassen sich alle Standardeinstellungen mit einer Anweisung
definieren. Weitere Aussichtspunkte können über die Methode C<viewpoint>
hinzugefügt werden. Der Parameter I<avatarSize> sichert, daß die Viewpoints
in der gleichen Höhe angeordnet werden in der sich der Betrachter bewegt.

Das folgende Beispiel ordnet alle sechs Standardansichten im Abstand von fünf
Metern um das Zentrum (4 3 0) an:

    $vrml->viewpoint_set('4 3 0',5);

=item viewpoint_auto_set

Setzt alle Parameter von C<viewpoint_set> automatisch, voraugesetzt das es
nach der Geometrieplazierung aufgerufen wird.

=item viewpoint_end

Beendet C<viewpoint_begin>.

=item directionallight

F<directionallight('direction', intensity, ambientIntensity, 'color', on)>

 direction         SFVec3f  '0 0 -1'
 intensity         SFFloat  1
 ambientIntensity  SFFloat  1
 color             SFColor  '1 1 1' #weiß
 on                SFBool   1

Die B<directionallight>-Methode beleuchtet Objekte in einer Szene mit parallelem
Licht gleicher Intensität. Der I<direction>-Parameter spezifiziert die Richtung
der Strahlen bezogen auf das lokale Koordinatensystem. Das Licht wird von
einer unendlich weit entfernten Quelle ausgestrahlt und beleuchtet nur die
Objekte der Gruppe, in der es sich befindet, bzw. deren untergeordnete
Gruppen. Der I<intensity>-Parameter spezifiziert die Intensität der Lichtquelle.
Ein Wert von 1 bedeutet maximale Helligkeit. Die Farbe des ausgesendeten
Lichtes bestimmt der I<color>-Parameter. Über den Parameter I<on> läßt sich der
Grundzustand der Lichtquelle angeben.

Alle durchgeführten übergeordneten Transformationen wirken sich auch auf die
Lichtquelle aus.

Beispiel:

    $vrml->directionallight("0 0 -1", 0.3);


=item sound

F<sound('url','description', 'location', 'direction', intensity, loop, pitch)>

 url         MFString []
 description SFString ""
 location    SFVec3f  '0 0 0'
 direction   SFVec3f  '0 0 1'
 intensity   SFFloat  1.0
 loop        SFBool   0
 pitch       SFFloat  1.0

Die I<sound>-Methode spezifiziert die räumliche Präsentation von Tönen in
einer VRML-Szene.

Der I<url>-Parameter spezifiziert die URL, von der der Klang geladen werden
soll. Die unterstützen Typen sind meistens WAV im unkomprimierten PCM-Format
und MPEG-1. Zusätzlich können viele VRML-Browser noch den MIDI-Dateityp 1
unter Verwendung des General MIDI Patch wiedergeben.

Der I<description>-Parameter gibt eine sprachliche Beschreibung der
Audio-Quelle an. Ein Browser muß den I<description>-Parameter nicht anzeigen,
kann es aber während der Wiedergabe des Klangs tun.

Der I<location>-Parameter bestimmt den Ort im lokalen Koordinatensystem, von
dem der Sound ausgestrahlt werden soll. Die B<sound>-Methode gibt keine Töne
ab, wenn sie nicht Teil der dargestellten Szene ist; d. h. wenn sie sich in
einem Teil eines LOD- oder Switch- Knotens befindet der ausgeschaltet ist.

Der I<direction>-Parameter spezifiziert die Richtung, in die der Sound
ausgestrahlt werden soll.

Der I<intensity>-Parameter spezifiziert die Wiedergabelautstärke. Der
Wertebereich geht von 0.0 bis 1.0. Bei einer Intensität von 1.0 wird der Ton
mit maximaler Lautstärke wiedergegeben; bei 0.0 hingegen herrscht Ruhe.

Der I<loop>-Parameter bestimmt, ob das Musikstück einmal oder fortlaufend
wiedergegeben werden soll.

Der I<pitch>-Parameter spezifiziert ein Vielfaches der Wiedergabefrequenz. Es
sind nur positive Werte gültig. Ein Wert von Null oder kleiner produziert
undefinierte Ergebnisse. Die Änderung des I<pitch>-Parameter erzeugt sowohl
eine Tonhöhenänderung als auch eine Änderung der Wiedergabegeschwindigkeit.
Ein Wert von 2.0 bedeutet, daß der Klang eine Oktave höher als normal
gespielt wird und doppelt so schnell. Bei einem gesampelten Klang ändert der
I<pitch>-Parameter die Wiedergabefrequenz. Im Falle einer MIDI (oder eines
anderen in Noten aufgezeichneten Musikstücks) wird das Tempo der Wiedergabe
erhöht und die MIDI-Steuerung entsprechend angepaßt, um den gewünschten
Effekt zu erzielen.

=back

=head2 Geometrien

Für die Darstellung von geometrischen Körpern gibt es eine Vielzahl von
Methoden. Sie benötigen grundsätzlich Dimensionsangaben wie Breite, Höhe oder
Radius. Darüber hinaus können über den Parameter I<appearance> die Farbe bzw.
die Oberflächeneigenschaften spezifiziert werden.

=over 4

=item box

F<box('size', 'appearance')>

 size       SFVec3f  '2 2 2' # Breite Höhe Tiefe
 appearance SFString ""      # siehe Material & Farbe


Die Methode B<box> definiert einen Quader mit dem Mittelpunkt (0 0 0) im
lokalen Koordinatensystem. Standardmäßig hat der Quader die Größe von zwei
Einheiten in jeder Richtung, jeweils von -1 bis +1. Der I<size>-Parameter
spezifiziert die Ausdehnung entlang der x-, y- und z-Achse und muß bei jeder
Komponente größer als 0.0 sein. Sind alle drei Angaben gleich, so wird aus
dem Quader ein Würfel. Der Parameter I<appearance> spezifiziert die Farbe
bzw. die Oberflächeneigenschaften. Texturen werden auf jede Fläche einzeln
projiziert.

Ein Quader erfordert nur die Darstellung von Außenflächen. Die Betrachtung
der Innenseiten führt zu undefinierten Ergebnissen.


=item cone

F<cone('bottomRadius height', 'appearance')>

 bottomRadius height SFVec2f '1 2'
 appearance          SFString "" # siehe Material & Farbe


Die Methode B<cone> spezifiziert einen Kegel, dessen Mittelpunkt (0 0 0) im
lokalen Koordinatensystem und dessen zentrale Achse auf der y-Achse liegt.
Der I<bottomRadius>-Parameter bestimmt den Radius des Kegelbodens und der
I<height>-Parameter die Höhe des Kegels. Standardmäßig hat der Kegel einen
Radius von 1.0 und eine Höhe von 2.0 mit der Spitze bei y = I<height>/2 und dem
Boden bei y = -I<height>/2. Beide, I<bottomRadius> und I<height>, müssen größer als
0.0 sein. Der Parameter I<appearance> spezifiziert die Farbe bzw. die
Oberflächeneigenschaften.

Ein Kegel erfordert nur die Darstellung von Außenflächen. Die Betrachtung der
Innenseiten führt zu undefinierten Ergebnissen.


=item cylinder

F<cylinder('radius height', 'appearance')>

 radius height SFVec2f  '1 2'
 appearance    SFString "" # siehe Material & Farbe


Die Methode B<cylinder> spezifiziert einen geschlossenen Zylinder (Abbildung 6)
mit dem Mittelpunkt (0 0 0) im lokalen Koordinatensystem, dessen zentrale
Achse auf der y-Achse liegt. Standardmäßig hat der Zylinder eine Ausdehnung
von -1 bis +1 in alle drei Richtungen. Der I<radius>-Parameter bestimmt den
Radius des Zylinders und der I<height>-Parameter die Höhe entlang der zentralen
Achse. Beide, I<radius> und I<height>, müssen größer als 0.0 sein. Der Parameter
I<appearance> spezifiziert die Farbe bzw. die Oberflächeneigenschaften.

Ein Zylinder erfordert nur die Darstellung von Außenflächen. Die Betrachtung
der Innenseiten führt zu undefinierten Ergebnissen.


=item line

F<line('from', 'to', radius, 'appearance', 'path')>

 from        SFVec3f   ""
 to          SFVec3f   ""
 radius      SFFloat   0 # 0 = Haarlinie
 appearance  SFString  ""
 path        SFEnum    "" # XYZ, XZY, YXZ, YZX, ZXY, ZYX

In VRML erfolgt die Positionierung eines Körpers durch die Angabe eines
Raumpunktes und der Richtung im Raum (Vektor). Diese Vorgehensweise erweist
sich dann als besonders nachteilig, wenn zwei Punkte durch einen Körper
miteinander verbunden werden müssen. Der VRML-Knoten C<IndexedLineSet> bietet
nur die Möglichkeit, zwei Punkte durch Linien in einer Standardstrichstärke
zu verbinden. Um eine variable Linienstärke zu realisieren, muß ein Zylinder
als Linienersatz dienen. Die Methode B<line> führt alle notwendigen Berechnungen
durch, um diesen Zylinder korrekt zu plazieren. Die Parameter I<from> und I<to>
bestimmen den Start- und Endpunkt der Linie. Der Parameter I<radius> gibt den
Radius des Zylinders vor, der für die Verbindung eingesetzt wird. Ob die
Linie einen direkten oder einen orthogonalen Verlauf entlang der x-, y- und
z-Achsen nehmen soll, spezifiziert der Parameter I<path>. Bei leerem Parameter
wird die direkte Verbindung gewählt.

In dem folgenden Beispiel erzeugt die erste Linie einen orthogonalen
Linienverlauf beginnend an der Position '1 -1 1', der sich zunächst entlang
der x-Achse bewegt, dann in Richtung der z-Achse und schließlich parallel zur
y-Achse an der Koordinate '-3 2 2' endet. Der Zylinder hat einen Durchmesser
von drei Zentimetern. Der zweite Zylinder verbindet beide Koordinaten auf
direktem Weg miteinander.

    new VRML(2)
    ->begin
      ->line('1 -1 1', '-3 2 2', 0.03, 'red', 'XZY')
      ->line('1 -1 1', '-3 2 2', 0.03, 'white')
    ->end
    ->print;

=item pyramid

F<pyramid('size', 'appearance')>

 size       SFVec3f  '2 2 2' # Breite Höhe Tiefe
 appearance SFString ""      # siehe Material & Farbe


Die Methode B<pyramid> definiert eine Pyramide mit dem Mittelpunkt (0 0 0) im
lokalen Koordinatensystem. Standardmäßig hat der Pyramide die Größe von zwei
Einheiten in jeder Richtung, jeweils von -1 bis +1. Der I<size>-Parameter
spezifiziert die Ausdehnung entlang der x-, y- und z-Achse und muß bei jeder
Komponente größer als 0.0 sein. Der Parameter I<appearance> spezifiziert die
Farbe bzw. die Oberflächeneigenschaften. Werden mehrere Farben angegeben
(durch Kommata getrennt), so wird jede Seite mit der entsprechen Farbe
belegt.

Beispiel:

    $vrml->pyramid('1 1 1','blue,green,red,yellow,white');

=item sphere

F<sphere(radius, 'appearance')>

 radius     SFFloat  1
 appearance SFString "" # siehe Material & Farbe

Die Methode B<sphere> spezifiziert eine Kugel mit dem Mittelpunkt (0 0 0) im
lokalen Koordinatensystem. Der I<radius>-Parameter bestimmt den Radius der Kugel
und muß größer als 0.0 sein. Der Parameter I<appearance> spezifiziert die Farbe
bzw. die Oberflächeneigenschaften.

Wenn eine Textur auf die Kugel gelegt wird, umhüllt sie die ganze Oberfläche,
beginnend von der Rückseite entgegen dem Uhrzeigersinn. Die Textur hat eine
Naht an der Rückseite, wo die Fläche x=0 die Kugel schneidet und die z-Werte
negativ sind.

Eine Kugel erfordert nur die Darstellung von Außenflächen. Die Betrachtung
der Innenseiten führt zu undefinierten Ergebnissen.


=item elevationgrid

F<elevationgrid(height, color, xDimension, zDimension, xSpacing, zSpacing,
creaseAngle, colorPerVertex, solid)>

 height          MFFloat  []
 color           MFColor  []  # bzw. Material & Farbe
 xDimension      SFInt32  0
 zDimension      SFInt32  0
 xSpacing        SFFloat  1.0
 zSpacing        SFFloat  1.0
 creaseAngle     SFFloat  0
 colorPerVertex	 SFBool   1
 solid           SFBool   0

Die Methode B<elevationgrid> spezifiziert ein Höhenmodell durch ein
regelmäßiges Gitter. Der Parameter I<height> gibt dabei eine Anzahl von
Höhenwerten vor zu denen jeweils ein Farbwert (bei I<colorPerVertex> gleich
1) gehört. Wird I<colorPerVertex> auf 0 gesetzt, so werden die Flächen
zwischen vier Punkten eingefärbt, d.h. es wird ein Farbwert pro Dimension
(x,z) weniger benötigt. Der Parameter I<height> kann als Referenz auf ein
Array - welches eine x-Zeile enthält - angegeben werden. In diesem Fall wird
die Anzahl der Elemente als I<xDimension> und die Anzahl der Zeilen als
I<zDimension> interpretiert. Sie sollte dann nicht nochmals ermittelt werden.
Wird der Parameter I<color> nicht als Referenz auf ein ARRAY übergeben, so
wird angenommen, daß es sich um eine Farb- bzw. Texturangabe handelt.

Beispiel:

    open(FILE,"<height.txt");
    my @height = <FILE>;
    open(COL,"<color.txt");
    my @color = <COL>;
    $vrml->navigationinfo(["EXAMINE","FLY"],200)
         ->viewpoint("Top","1900 6000 1900","TOP")
         ->elevationgrid(\@height, \@color, undef, undef, 250, undef, 0)
	 ->print;


=item text

F<text('string', 'appearance', 'font', 'align')>

 string     MFString []
 appearance SFString "" # siehe Material & Farbe
 font       SFString '1 SERIF PLAIN'
 align      SFEnum   'BEGIN' # BEGIN, MIDDLE, END


Die Methode B<text> spezifiziert eine flache, zweiseitige Zeichenkette, die
in der z-Ebene des lokalen Koordinatensystems positioniert wird. Der
Parameter string kann eine Liste von Zeichenketten enthalten, wobei jeder
Eintrag in einer neuen Zeile dargestellt wird. Der Parameter I<appearance>
spezifiziert die Farbe bzw. die Oberflächeneigenschaften, die für den
kompletten Text gültig ist. Der Parameter font gliedert sich in drei Teile
I<size>, I<family> und I<style>, jeweils durch ein Leerzeichen getrennt. Der
erste Wert I<size> spezifiziert die Schriftgröße (Schriftgrad), bezogen auf
das lokale Koordinatensystem der C<text>-Methode. Er muß immer größer als 0.0
sein. Der zweite Wert I<family> enthält eine Zeichenkette in Großbuchstaben,
welche die Font-Familie spezifiziert. Der Browser bestimmt jedoch
letztendlich, welcher Font aus dieser Familie zum Einsatz kommt.
Üblicherweise werden von den Browsern mindestens SERIF für einen Serif-Font
wie Times Roman, SANS für einen Sans-Serif-Font wie Helvetica und TYPEWRITER
für einen Font mit konstanter Buchstabenbreite wie Courier unterstützt. Ein
leerer Wert für I<family> ist identisch mit SERIF. Der Parameter I<style>
kann die Werte PLAIN, BOLD, ITALIC und BOLDITALIC annehmen.

    PLAIN  (keine Besonderheiten, Voreinstellung)
    BOLD   (fett)
    ITALIC (kursiv)
    BOLDITALIC (fett und kursiv)

Der Parameter I<align> gibt die Ausrichtung des Textes an. Es stehen folgende
Werte zur Verfügung:

    BEGIN  bzw. LEFT   (linksbündig, Voreinstellung)
    MIDDLE bzw. CENTER (zentriert)
    END    bzw. RIGHT  (rechtsbündig)

=item billtext

F<billtext('string', 'appearance', 'font', 'align')>

 string     MFString []
 appearance SFString "" # siehe Material & Farbe
 font       SFString '1 SERIF PLAIN'
 align      SFEnum   'BEGIN' # BEGIN, MIDDLE, END


Die Methode B<billtext> ist äquivalent zur Methode C<text> mit der
zusätzlichen Eigenschaft, daß der Text immer dem Betrachter zugewandt bleibt.
Sie kombiniert die Methoden B<billboard> und C<text>, da es häufig vorkommt,
daß die Textinformationen einer Szene aus allen Richtungen lesbar sein
müssen.

=back

=head2 Material & Farbe

Das Erscheinungsbild von geometrischen Objekten (engl. Shape) wird in VRML
2.0 durch den Appearance-Knoten bestimmt. Dieser kann als Kindknoten einen
Material- und einen Texture-Knoten enthalten. In VRML 1.0 definiert der
letzte Material- bzw. Texture-Knoten das Aussehen aller darauf folgenden
Objekte. Diese unterschiedliche Verfahrensweise zur Angabe des
Erscheinungsbildes eines geometrischen Objekts erschwert die flexible Ausgabe
einer Szene in einer beliebigen Spezifikation. Das VRML-Modul ermöglicht
jedoch eine einfache und benutzerfreundliche Farb- bzw. Texturangabe. Es
bietet verschiedene Varianten der Materialzusammensetzung nach folgender
Schema:

    'Eigenschaft1=Liste1; Eigenschaft2=Farbe1,Farbe2; ...'

wobei I<Eigenschaft> die Werte:

    a - ambientColor (nur VRML 1.0)
    d - diffuseColor
    e - emissiveColor
    s - specularColor

    ai - ambientIntensity (nur VRML 2.0)
    sh - shininess
    tr - transparency

    tex - filename, wrapS, wrapT

    def    - benennt den Appearance-Knoten
    defmat - benennt den Material-Knoten
    deftex - benennt den Image- bzw. MovieTexture-Knoten

annehmen kann und I<Liste> eine Anzahl von Materialien definiert, die durch
Kommata getrennt werden müssen. Das Kürzel für einen Farbwert besteht dabei
aus einem Buchstaben und das Kürzel einer Intensität aus zwei Buchstaben.
Drei und mehr Buchstaben sind für Definitionen und Texturen vorgesehen. Das
Modul erkennt selbständig, ob es sich um eine ImageTexture (GIF, JPEG, PNG,
BMP) oder um ein Video (AVI, MPEG, MOV) handelt. Mehrere Eigenschaften können
kombiniert werden, indem diese durch ein Semikolon voneinander getrennt
werden. Farbwerte können als RGB-Tripel oder als Name angegeben werden.
Es gibt vier Schreibweisen, um eine Farbe (z. B. intensives Gelb) zu
definieren.

    '1 1 0' (VRML-Standard)
    'FFFF00' oder 'ffff00'
    '255 255 0'
    'yellow'

Die beiliegende Version des VRML-Moduls enthält alle X11-Farbnamen. Jedem
Farbnamen kann ein zweistelliger Zahlenwert folgen, der die Helligkeit linear
verringert. Dieser prozentuale Anteil muß von dem Farbnamen durch ein
spezielles Zeichen ( % _ ) getrennt werden. Hier bietet sich das
Prozentzeichen als intuitive Gedankenstütze an. Von der Verwendung dieses
Zeichens innerhalb eines Parameters einer URL-Adresse ist jedoch abzuraten,
da Prozentzeichen, die von Ziffern gefolgt werden, in entsprechende
ASCII-Zeichen umgewandelt werden. Es wird deshalb empfohlen, in URL-Adressen,
insbesondere im QUERY_STRING, den Unterstrich (_) als Trennsymbol zu
verwenden !

Analog zum vorherigen Beispiel können vier verschiedene Schreibweisen
eingesetzt werden, um die Intensität einer Farbe (z. B. Gelb) zu verringern.

    '.5 .5 0' (VRML-Standard)
    '808000'
    '128 128 0'
    'yellow%50'

Abschließend noch zwei Beispiele für identische Farbwerte:

    yellow%100 = yellow_100 = yellow (gelb)

    white%0 = black (schwarz)

Eine Liste der verfügbaren Farbnamen befindet sich im Modul VRML::Color.

=over 4

=item appearance

F<appearance('Typ=Wert1,Wert2 ; Typ=...')>

Die Methode B<appearance> wird implizit beim Gebrauch der Geometriemethoden
aufgerufen. Sie realisiert die obige Synatx. Normalerweise wird sie nicht
anderweitig benötigt.

=back

=head2 Interpolatoren

Für die Erstellung von Animationen sind Interpolatoren unentbehrlich. Sie stehen
für fast alle Datentypen zur Verfügung. Grundsätzlich besitzen alle
Interpolatoren als Parameter einen Namen, eine Liste von Stützstellen und eine
dazugehörige Liste mit Funktionswerten. Die Stützstellen, auch C<keys> genannt,
liegen immer im Bereich von 0.0 bis 1.0. Zu jedem C<key> muß es einen Funktionswert
vom Typ des Interpolators geben. Zwischen den C<keys> wird linear interpoliert. Um
eine bessere Interpolation als die stückweise lineare Interpolation zu erzielen,
muß man sich einen eigenen Interpolator schreiben. Für ganze Zahlen gibt es
keinen Interpolator.

=over 4

=item interpolator

F<interpolator('name','type',[keys],[keyValues])>

 name      SFString ""
 type      SFEnum   "" # Color, Coordinate, Normal, Orientation,
                       # Position und Scalar
 keys      MFFloat  [] # [0,1]
 keyValues MF...    [] # Typ des Interpolators

Die Methode B<interpolator> erzeugt einen benannten Interpolator, der linear
zwischen den Funktionswerten des im Parameters I<type> spezifizierten Datentyps
interpoliert. Als Typen stehen zur Auswahl: Color, Coordinate, Normal,
Orientation, Position und Scalar. Der Parameter I<name> enthält den Bezeichner,
über den der Interpolator beispielsweise in einer C<route>-Methode referenziert
werden kann.

Beispiel:

    $vrml->interpolator('RotBlau', 'Color', [0,1], ['1 0 0', '0 0 1']);


=back

=head2 Sensoren

Sensoren ermöglichen eine direkte Wechselwirkung des Betrachters mit Objekten
einer Szene. Die Sensoren in VRML 2.0 gliedern sich in zwei Kategorien:
Geometriesensoren und Zeitsensoren. Ein Teil der Geometriesensoren - Cylinder-,
Plane- und SphereSensor - liefern Ereignisse, wenn die mit ihnen verbundenen
Objekte aktiviert und bewegt werden. Andere Sensoren, wie der Proximity- oder
der Visibility-Sensor, reagieren schon beim Betreten oder Sichtbarwerden eines
Bereiches. Die erzeugten Ereignisse können von Interpolator- oder Script-Knoten
verarbeitet werden, die wiederum Ereignisse für andere Knoten generieren. Die
Ereignisse einiger Sensoren können auch direkt an einen Transform-Knoten
weitergeleitet werden.

Für den Ablauf von Animationen ist der TimeSensor von besonderer Bedeutung. Er
kann in kontinuierlichen Abständen Ereignisse liefern, die an Skripte oder
Interpolatoren gesendet werden.

Alle Sensoren benötigen grundsätzlich einen Namen für die referenzierende
C<route>-Anweisung. Dieser wird immer im Parameter I<name> spezifiziert.

=over 4

=item cylindersensor

F<cylindersensor('name',maxAngle,minAngle,diskAngle,offset,autoOffset,enabled)>

 name       SFString ""
 maxAngle   SFFloat  undef
 minAngle   SFFloat  0
 diskAngle  SFFloat  15
 offset     SFFloat  0
 autoOffset SFBool   1
 enabled    SFBool   1

Der Cylinder-Sensor generiert Ereignisse, sobald der Benutzer einen virtuellen
Zylinder anklickt.

=item planesensor

F<planesensor('name',maxPosition,minPosition,offset,autoOffset,enabled)>

 name         SFString  ""
 maxPosition  SFVec2f  undef
 minPosition  SFVec2f  '0 0'
 offset       SFVec3f  '0 0 0'
 autoOffset   SFBool  1
 enabled      SFBool  1

Der Plane-Sensor generiert Ereignisse, sobald der Benutzer eine virtuelle Ebene
anklickt.

=item proximitysensor

F<proximitysensor('name',size,center,enabled)>

 name    SFString ""
 size    SFVec3f  '0 0 0'
 center  SFVec3f  '0 0 0'
 enabled SFBool   1

Der Proximity-Sensor generiert Ereignisse, sobald sich der Benutzer innerhalb
eines bestimmten (quaderförmigen) Bereichs um ein bestimmtes Objekt bzw. einen
bestimmten Koordinatenpunkt bewegt.

=item spheresensor

F<spheresensor('name',offset,autoOffset,enabled)>

 name       SFString   ""
 offset     SFRotation '0 1 0 0'
 autoOffset SFBool     1
 enabled    SFBool     1

Der Sphere-Sensor generiert Ereignisse, sobald der Benutzer eine virtuelle Kugel
anklickt.

=item timesensor

F<timesensor('name',cycleInterval,loop,startTime,stopTime,enabled)>

 name          SFString ""
 cycleInterval SFFloat  1
 loop          SFBool   0
 startTime     SFFloat  0
 stopTime      SFFloat  0
 enabled       SFBool   1

Der Time-Sensor generiert Ereignisse, die Zeitwerte enthalten. Diese
Zeitwerte können beispielsweise Animationen steuern.

=item touchsensor

F<touchsensor('name',enabled)>

    name    SFString ""
    enabled SFBool   1

Der Touch-Sensor generiert Ereignisse, sobald sich der Benutzer mit dem
Mauszeiger über ein bestimmtes Objektteil bewegt und dieses anklickt.

Das folgende Beispiel stellt eine weiße Kugel dar, die bei Aktivierung mit rotem
Licht bestrahlt wird.

Beispiel:

    $vrml
    ->begin
	->touchsensor('Schalter')
	->sphere(1,'white')
	->def('Licht')->directionallight("", 1, 0, 'red', 0)
	->route('Schalter.isActive', 'Licht.on')
    ->end
    ->print->save;

=item visibitysensor

F<visibitysensor('name',size,center,enabled)>

    name    SFString ""
    size    SFVec3f  '0 0 0'
    center  SFVec3f  '0 0 0'
    enabled SFBool   1

Der Visibility-Sensor generiert Ereignisse, sobald ein Teil eines
quaderförmigen Bereiches in das Blickfeld des Betrachters eintritt oder aus
dem Blickfeld verschwindet.

=back

=head2 Sonstiges

=over 4

=item route

F<route('from','to')>

 FROM.feldname SFString ""
 TO.feldname   SFString ""

Die Methode B<route> stellt die Verbindung zwischen einem Knoten, der Ereignisse
sendet, und einem Knoten, der dieses Ereignis empfängt her. Das Verständnis der
Beziehungen zwischen den Sende- und Empfangsfeldern der jeweiligen Knoten ist
Voraussetzung für das erfolgreiche Weiterleiten (routen) von Ereignissen. Der
Parameter I<FROM.feldname> spezifiziert das Feld eines benannten Knotens, von
dem das Ereignis gesendet wird. Der Parameter I<TO.feldname> spezifiziert das
Feld eines benannten Knotens, welches das Ereignis erhalten soll. Als Werte
dieser Parameter können nur mit def benannte Objekte verwendet werden, bei denen
die Datentypen übereinstimmen. Ein Beispiel für die Weiterleitung von
Ereignissen ist im Abschnitt L<Sensoren> zu finden.

=item def

F<def('name')>

 name SFString ""

Die Benennung eines Knotens ist Grundvoraussetzung für die Wiederverwendung
(Instanzierung) und das Weiterleiten von Ereignissen. Namen von Knoten,
Feldern, Ereignissen und Prototypen dürfen nicht mit einer Ziffer beginnen
und keines der folgenden Zeichen enthalten:

    Steuerzeichen (ASCII 0 bis 31)
    Leerzeichen
    einfache und doppelte Anführungszeichen
    Kommentarzeichen #
    Komma, Punkt und Semikolon
    Plus- und Minus-Zeichen
    Klammern
    Backslash

Beispiel:

    $vrml->def('Kugel')->sphere(1,'red')

=item use

F<use('name')>

 name SFString ""

Die Methode B<use> dient der Referenzierung bzw. Instanzierung eines mit der
Methode def definierten Objekts. Als einzigen Parameter benötigt sie den
Namen des Objekts.

Beispiel:

    $vrml->use('Kugel')

=back

=head1 SEE ALSO

VRML::VRML1

VRML::VRML1::Standard

VRML::VRML2

VRML::VRML2::Standard

VRML::Base

VRML::Color

Siehe auch http://www.gfz-potsdam.de/~palm/vrmlperl/ für weitere
Informationen zu den F<VRML-Modulen> und wie man sie einsetzen kann.

=head1 BUGS

Nicht alle Methoden wurden ausgiebig getestet. Manche Programmierer würden
sicher die Reihenfolge der Parameter anders wählen. Ich arbeiete daran, in
einer der nächsten Versionen benannte Parameter einzusetzen.

=head1 AUTHOR

Hartmut Palm F<E<lt>palm@gfz-potsdam.deE<gt>>

Homepage http://www.gfz-potsdam.de/~palm/

=cut
