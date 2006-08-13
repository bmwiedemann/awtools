package awmap;

$::pixelpersystem=13; # for 12 planet status lines
$::mapsize=151;
if($ENV{REMOTE_USER} eq "xr") {$::mapsize+=10}
$::mapxoff=-int(($::mapsize-1)/2);
$::mapyoff=-int(($::mapsize-1)/2);

sub maptoimg($$;$$) { my($x,$y,$mapxoff,$mapyoff)=@_;
  if(! defined($mapxoff)) {$mapxoff=$::mapxoff}
  if(! defined($mapyoff)) {$mapyoff=$::mapyoff}
  return (($x-$mapxoff)*$::pixelpersystem, ($y-$mapyoff)*$::pixelpersystem);}
sub imgtomap($$;$$) { my($x,$y,$mapxoff,$mapyoff)=@_;
  if(! defined($mapxoff)) {$mapxoff=$::mapxoff}
  if(! defined($mapyoff)) {$mapyoff=$::mapyoff}
  return (int($x/$::pixelpersystem)+$mapxoff, int($y/$::pixelpersystem)+$mapyoff);}

1;
