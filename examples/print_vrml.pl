use VRML;

print VRML->new->version(1.1)->browser("LIVE3D")->backgroundimage("starbak.gif")->cube(1,"1 2 3","orange")->vrml;
