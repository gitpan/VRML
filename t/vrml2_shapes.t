print "1..6\n";

use VRML;
$vrml = new VRML(2);
if ($vrml->box("5 1 3","pink")) { print "ok 1\n"; } else { print "not ok 1\n";} ;
if ($vrml->cone("1 3","red")) { print "ok 2\n"; } else { print "not ok 2\n";} ;
if ($vrml->cube(5,"green")) { print "ok 3\n"; } else { print "not ok 3\n";} ;
if ($vrml->cylinder("2 4","blue")) { print "ok 4\n"; } else { print "not ok 4\n";} ;
if ($vrml->sphere("5","yellow")) { print "ok 5\n"; } else { print "not ok 5\n";} ;
if ($vrml->text("Hallo world","white","10 BOLD SERIF")) { print "ok 6\n"; } else { print "not ok 6\n";} ;
