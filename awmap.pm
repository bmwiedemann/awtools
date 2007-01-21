package awmap;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = 
qw($pixelpersystem $mapsize $mapxoff $mapyoff);

our $pixelpersystem=13; # for 12 planet status lines and 1 border
our $mapsize=151;
if($ENV{REMOTE_USER} eq "xr") {$mapsize+=10}
our $mapxoff=-int(($mapsize-1)/2);
our $mapyoff=-int(($mapsize-1)/2);

sub maptoimg($$$$) { my($x,$y,$mapxoff,$mapyoff)=@_;
  return (($x-$mapxoff)*$pixelpersystem, ($y-$mapyoff)*$pixelpersystem);}
sub imgtomap($$$$) { my($x,$y,$mapxoff,$mapyoff)=@_;
  return (int($x/$pixelpersystem)+$mapxoff, int($y/$pixelpersystem)+$mapyoff);}

1;
