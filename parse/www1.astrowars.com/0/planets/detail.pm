use strict;
use awparser;
use awinput;

#my @n;
foreach my $line (m{<tr align=center(.*?)</td></tr>}gs) {
   if($line=~m{([0-9.+]+)</td><td><img src="/images/dot.gif" height="10" width="([0-9.]+)"><img src="/images/leer.gif" height="10" width="([0-9.]+)"></td>}) {
      my $num=$1+$2/340;
      my $n1=$`;
      my($n2)=($n1=~m{([^>]+)</a>});
      $n2=~s/ +//g;
      my($n3)=($line=~m/([0-9\/]+)(?:<\/a>)?\s*$/);
      my @extra=();
		my $label2="remain";
      # split ship remaining numbers
      if($n3=~s{^(\d+)/}{}) {push(@extra,pp=>int($1));}
      $n3+=0;
      if($n2 eq "Population") {
         m{id=23>\+(\d+)</a></td>} and push(@extra,hourly=>int($1));
      }
		if($n2 eq "ProductionPoints") {$label2="hourly"}
      $d->{lc($n2)}={num=>$num, $label2=>$n3, @extra};
#      push(@n, [$n2,$num,$1]);
   } elsif($line=~m{^><td colspan="5">\s*(.*) (\d+)}) {
		$d->{name}=$1;
		$d->{pid}=$2+0;
		$d->{sid}=systemname2id($1);
	} elsif($line=~m{^ bgcolor="#202060"><td>#(\d+)}) {
		$d->{n}=int($1);
	}
#	elsif($line=~m{Garrison</td><td>qty}) {
#	} else { $d->{debug}=$line; }
}
#$d->{test}=\@n;

2;
