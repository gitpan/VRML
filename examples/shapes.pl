use VRML;

$vrml = new VRML;
$vrml->sphere([4, 3, 2],undef,"red")->cone([2, 3],"0 3 0")->print;
