print "1..1\n";

use VRML;
new VRML->browser("Live3D")->cube("1 2 3","gray")->as_string;

print "ok 1\n";
