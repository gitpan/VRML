print "1..5\n";

use VRML;
$vrml = new VRML;
if ($vrml->box("5 1 3","pink")) { print "ok 1\n"; } else { print "not ok 1\n";} ;
if ($vrml->cone("1 3","red")) { print "ok 2\n"; } else { print "not ok 2\n";} ;
if ($vrml->cube(5,"green")) { print "ok 3\n"; } else { print "not ok 3\n";} ;
if ($vrml->cylinder("2 4","blue")) { print "ok 4\n"; } else { print "not ok 4\n";} ;
if ($vrml->sphere("5","yellow")) { print "ok 5\n"; } else { print "not ok 5\n";} ;
