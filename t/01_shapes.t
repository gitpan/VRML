print "1..4\n";

use VRML;
$vrml = new VRML;
if ($vrml->cone("5","1 2 3","red")) { print "ok 1\n"; } else { print "not ok 1\n";} ;
if ($vrml->cube("5","1 2 3","green")) { print "ok 2\n"; } else { print "not ok 2\n";} ;
if ($vrml->cylinder("5","1 2 3","blue")) { print "ok 3\n"; } else { print "not ok 3\n";} ;
if ($vrml->sphere("5","1 2 3","yellow")) { print "ok 4\n"; } else { print "not ok 4\n";} ;
