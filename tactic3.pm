my %rentability=qw"hf 0.9 rf 1.5 gc 1 rl 0.8 sb 0.5";
#my %rentability=qw"hf 0.9 rf 1 gc 1 rl 1 sb 1";

# returns value>0
sub rentability($$){my ($p,$building)=@_;
  if($building eq "gc") {
    return $rentability{$building}+$$p{"rf"}/10;
  }
  return $rentability{$building};
}

sub findtarget($) { my($p)=@_;
  my ($min,$mint);
  for my $t(@buildings) {
    my $val=$prod[$$p{$t}+1]/rentability($p,$t);
#    print "$t:$val ";
    if(!defined($min) || $val<$min) {
      $min=$val;
      $mint=$t;
    }
  }
#  print "$mint:$min\n";
  return $mint;
}

sub spend1()
{ 
  foreach my $p (@planet) {
    my $val=$$p{rf}+$$p{pop};
    do {
      $target=findtarget($p);
    } while(build($p,$target,0));
  }
}

1;
