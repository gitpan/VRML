use VRML;

print VRML->new->browser("LIVE3D")->backgroundimage("starbak.gif")->cube(2,"orange")->as_string;
