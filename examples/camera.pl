use VRML;

$vrml = new VRML (1.0);
$vrml->browser('Live3D')
->cameras_begin(1)
  ->camera_set(undef,5)
  ->camera("Red","0 0 -5","0 1 0 180")
->cameras_end
->anchor_begin("#Red","To Red Side")
  ->cube('2 3 1','yellow,red,green')
->anchor_end
->print;
