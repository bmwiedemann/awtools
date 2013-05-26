use strict;
use awparser;

if($::options{url}=~m/Trade\/$/) {
	my $n=0;
parsetable($_, sub {
		my($line, $start, $a)=@_;
		return if($line=~m/th scope="col"/);
		my $key=$a->[0];
		$key=~s{.*>([^<>]*)</a>}{$1};
		$key=~s/ /_/g;
		my $value=$a->[1];
		if($value=~s/^\$//) {
			$key.="_ad";
			$value=~s/\.//g;
		   $value=~s/,/./;
		}
		$value=~s/%$//;
		#$d->{"x".$n++}="$key=>$value";
		$d->{$key}=$value;
	});

   my @p=();
   my @arti=();
   foreach my $line (m{<tr bgcolor=(.+?)</tr>}g) {
      # fetch prices:
      if(my ($code,$name,$value)=($line=~m{<a href=Stats/([0-9a-z-]+)\.html>([^<]+)</a></td><td align=right>\$([0-9.,-]+)})) {
#         $d->{$code}=[$code,$name,$value];
         push(@p, {code=>$code,name=>$name,value=>unprettyprint($value)});
      } elsif($line=~m{#(\d+)'><td>&nbsp;([a-zA-Z ]+ \d)</td><td align=center>(\d+)</td>}) {
         my $active=0;
         if($1 ne "404040") {
            $d->{activeartifact}=$2;
            $active=1;
         }
         push(@arti, {name=>$2, quantity=>int($3), active=>$active});
      } elsif($line=~m{id=33>Supply Units</a></td><td align=center>(\d+)/(\d+)}) {
         $d->{su}={own=>int($1), max=>int($2)};
      } elsif($line=~m{id=48>Astro Dollars</a></td><td align=center>\$([-+0-9.,]+)</b>}) {
         $d->{ad}=unprettyprint($1);
      } else {
         $d->{debug}=$line;
      }
   }
   $d->{price}=\@p;
   $d->{artifact}=\@arti;

   if(m{<tr align=center bgcolor='#303030'><td>Trade Revenue</td><td>([+-]?\d+)%</td></tr>}) {
      $d->{traderevenue}=int($1);
   }
}

2;
