use VRML;

$vrml = new VRML(1);
$vrml
->camera_set("",20)
->transform_begin("0 3 -10; r=0 1 1 45")
  ->cube(4,"green")
->transform_end
->at("0 -8 0")->sphere("4 3 2","blue")->back
->at("0 -8 4")->text("Hallo world","white","10 BOLD SERIF","CENTER")->back
->line("0 -8 0","0 3 -10",.3,"yellow")
->save
->print;
