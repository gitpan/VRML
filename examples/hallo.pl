use VRML;

$vrml = new VRML(2);
$vrml
->begin
->at("2 2 2")->fixtext("Hallo world ÄÖÜß","yellow")->back
->touchsensor("VIDEO")
->cube("","def=MPG; tex=file:///d|/movie/mpg/wow.mpg")
->end
#->routetime("VIDEO","MPG")
->save
->print;
