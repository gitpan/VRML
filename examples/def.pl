use VRML;

$vrml = new VRML;
$vrml->version(1.0)
->begin("Main")
->  cameras_begin()
->    camera_set("1.5 3 0",5)
->  end
->  material("yellow,green,red")
->  def("blue_cube")->cube(1,"","blue")
->  cube(0.5,"3 0 0")
->  use("blue_cube")
->  transform("0 2 0")
->  use("blue_cube")
->  transform("0 2 0")
->  use("blue_cube")
->  transform("0 2 0")
->  def("red_cube")->cube(.3,"","red")
->end
->print;
