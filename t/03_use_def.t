print "1..1\n";

use VRML;

$vrml = new VRML;
$vrml->version(1.1)
->begin("Main")
->  cameras_begin(1)
->    camera_set("1.5 3 0",5)
->  end
->  material("yellow,green,red")
->  def("blue_cube",sub{$vrml->cube(1,"","blue")})
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

print "ok 1\n";
