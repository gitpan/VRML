use VRML;

open(FILE,"<height.txt");
my @height = <FILE>;
open(COL,"<color.txt");
my @color = <COL>;

$vrml = VRML->new(2);
$vrml
->navigationinfo(["EXAMINE","FLY"],200)
->viewpoint("Top","1900 6000 1900","TOP")
->elevationgrid(\@height, \@color, undef, undef, 250, undef, 0)
->save;