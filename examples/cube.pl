use VRML;

$vrml = new VRML(2);
$vrml
->camera_set("",20)
->transform("0 3 -10; r=0 1 1 45")
  ->cube(4,"tex=file:///D|/Palm/Hartmut/wrl/dec.gif")
->end
->at("0 -8 0")->sphere("4 3 2","blue")->end
->at("0 -8 4")->text("Hallo world","white","10 BOLD SERIF")->end
->line("0 -8 0","0 3 -10",.3,"yellow")
->save
->print;
