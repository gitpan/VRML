use VRML;

print VRML->new->browser("LIVE3D")->background("black", "starbak.gif")->cube(2,"orange")->as_string;
