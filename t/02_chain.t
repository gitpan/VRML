print "1..1\n";

use VRML;
$vrml = new VRML;
$vrml->version("VRML 1.1 ascii")->browser("Live3D")->cube(5,"1 2 3","gray");

print "ok 1\n";
