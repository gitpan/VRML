use VRML::VRML1::Standard;

$vrml = new VRML::VRML1::Standard;
$vrml->VRML_head("#VRML V1.0 ascii")
->Separator('Demo Cube')
->Cube(5,3,2)
->End
->VRML_print;
