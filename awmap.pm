$::pixelpersystem=13; # for 12 planet status lines
$::mapsize=81;
$::mapxoff=-int(($mapsize-1)/2);
$::mapyoff=-int(($mapsize-1)/2);

sub maptoimg($$) { my($x,$y)=@_;
 return (($x-$mapxoff)*$pixelpersystem, ($y-$mapyoff)*$pixelpersystem);}
sub imgtomap($$) { my($x,$y)=@_;
 return (int($x/$pixelpersystem)+$mapxoff, int($y/$pixelpersystem)+$mapyoff);}

1;
