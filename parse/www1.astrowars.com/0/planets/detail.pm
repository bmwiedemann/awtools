use strict;
use awparser;

m{<tr align=center bgcolor="#202060"><td>#(\d+)</td><td><a href=/0/Glossary//\?id=7>lvl</a></td>};
$d->{n}=int($1);
my @a=m{id=23>\+(\d+)</a></td><td> (\d+)</td><td><img src="/images/dot.gif" height="10" width="([0-9.]+)"><img src="/images/leer.gif" height="10" width="([0-9.]+)"></td><td>\n(\d+)</td></tr>};
{
   my @b=splice(@a,2,2);
   $a[1]+=$b[0]/340;
   for my $a (@a) {$a+=0}
}
$d->{poplevel}=\@a;

my @n;
my $n=0;
foreach my $line (m{<tr align=center(.*?)</td></tr>}gs) {
   if($line=~m{([0-9.+]+)</td><td><img src="/images/dot.gif" height="10" width="([0-9.]+)"><img src="/images/leer.gif" height="10" width="([0-9.]+)"></td>}) {
      my $num=$1+$2/340;
      my $n1=$`;
      my($n2)=($n1=~m{([^>]+)</a>});
      $n2=~s/ +//g;
      my($n3)=($line=~m/([0-9\/]+)(?:<\/a>)?\s*$/);
      my @extra=();
      # split ship remaining numbers
      if($n3=~s{/(\d+)$}{}) {push(@extra,int($1));}
      $n3+=0;
      if($n2 eq "Population") {
         m{id=23>\+(\d+)</a></td>} and push(@extra,int($1));
      }
      $d->{lc($n2)}=[$num,$n3,@extra];
#      push(@n, [$n2,$num,$1]);
   }
}
#$d->{test}=\@n;

2;
