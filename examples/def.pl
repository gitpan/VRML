use VRML;

$vrml = new VRML(1);
$vrml
->begin
->  cameras_begin()
->    camera_set("1.5 3 0",5)
->  cameras_end
->  def("blue_cube")->cube(1,"blue")
->  at("3 0 0")->sphere(0.5)->end
->  transform("0 2 0")
->  use("blue_cube")
->  transform("0 2 0")
->  use("blue_cube")
->  transform("0 2 0")
->  use("blue_cube")
->  transform("0 2 0")
->  def("red_cube")->cube(.3,"red")
->  end
->  end
->  end
->  end
->end
->print
->save;
