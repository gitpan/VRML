use VRML;

$vrml = new VRML (1.0);
$vrml->browser('Live3D')
->cameras_begin(1)
  ->camera_set(5)
  ->camera("Red","0 0 -5","0 1 0",180)
->end
->anchor_begin("#Red","To Red Side")
->cube('2 3 1','r=45','yellow,red,green')
->end
->print;
