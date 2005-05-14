my %colormap;
sub initrgb() {
  open(RGB, "< rgb.txt");
  while(<RGB>) {
    next if(/!/);
    if(m/^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\w+[ a-zA-Z0-9]*)$/) {
      my $colname=$4; my($r,$g,$b)=($1,$2,$3);
      $colname=~s/\s+//;
      $colormap{$colname}=[$r, $g, $b];
    }
  }
}
sub getrgb($) {
  if(!$_[0]) {return undef};
  my $entry=$colormap{$_[0]};
  if(!$entry) {
    print "color \"$_[0]\" not found\n";
    return undef;
  }
  my @ret=@$entry;
#  print "color: ".join(", ",@ret);
  return @ret;
}
initrgb();

sub mapcoloralloc($) { my($img)=@_;
our %colorindex;
for my $c (qw"black white gray red", @::statuscolor, @::relationcolor) {
  my @rgb=getrgb($c);
  next if !@rgb || !defined $rgb[0];
  $colorindex{$c}=$img->colorAllocate(@rgb);
}
our $axiscolor=$img->colorAllocate(getrgb("blue"));
our $lightgridcolor=$img->colorAllocate(getrgb("gray83"));
our $darkgridcolor=$img->colorAllocate(getrgb("gray34"));
}

sub writeimg($) { my($img,$name)=@_;
  open(OUT, "> $name") or die $!;
  binmode OUT;
  print OUT $img->png();
  close OUT;
}

1;
