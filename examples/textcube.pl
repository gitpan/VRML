use VRML;

$vrml = new VRML;
$vrml->version(1.1)
->textcube(10,"0 3 0","red","TextCube1")
->textcube(14,"0 1 -6","yellow","TextCube2")
->print
->display;
