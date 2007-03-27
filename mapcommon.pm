package mapcommon;
use strict;
use GD;
use awstandard;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw($axiscolor $lightgridcolor $darkgridcolor %colorindex &mapcoloralloc &writeimg);

my %colormap;
our %colorindex;

# load RGB data for color names
sub initrgb() {
  open(RGB, "< $awstandard::codedir/rgb.txt") or die "Content-type: text/html\n\nerror opening rgb.txt $!\n";
  while(<RGB>) {
    next if(/!/);
    if(m/^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\w+[ a-zA-Z0-9]*)$/) {
      my $colname=$4; my($r,$g,$b)=($1,$2,$3);
      $colname=~s/\s+//;
      $colormap{$colname}=[$r, $g, $b];
    }
  }
  close(RGB);
}

# convert a standard color-name to RGB array
sub getrgb($) {
  if(!$_[0]) {return (0,0,0)};
  my $entry=$colormap{$_[0]};
  if(!$entry) {
#    print "color \"$_[0]\" not found\n";
    return undef;
  }
  my @ret=@$entry;
#  print "color: ".join(", ",@ret);
  return @ret;
}

# allocate commonly used colors
sub mapcoloralloc($) { my($img)=@_;
   for my $c (qw"black white gray dimgray red", @awstandard::statuscolor, @awstandard::relationcolor) {
     my @rgb=getrgb($c);
     next if !@rgb || !defined $rgb[0];
     $colorindex{$c}=$img->colorResolve(@rgb);
   }
   our $axiscolor=$img->colorResolve(getrgb("blue"));
   our $lightgridcolor=$img->colorResolve(getrgb("gray83"));
   our $darkgridcolor=$img->colorResolve(getrgb("gray34"));
}

# write a png to file $name
sub writeimg($$) { my($img,$name)=@_;
  open(OUT, "> $name") or die "failed writing $name: $!";
  binmode OUT;
  print OUT $img->png();
  close OUT;
}

BEGIN { initrgb();}

1;
