use strict;
use awparser;
use awstandard;

foreach my $what ("Culture", "Science") {
   if(my @a=m!$what.*href="/0/Glossary//\?id=23">\(\+(\d+) per hour\)</a>((?:\s<b>[+-]\d+%)|)!) {
      $a[1]=~s/.*([+-]\d+).*/$1/;
      $a[1]||=0;
      foreach my $a (@a) {$a+=0}
      $d->{"\L$what"}=\@a;
   }
}


my @science;
foreach my $sci (@awstandard::sciencestr) {
   if(m!$sci</a> </td><td>(\d+)</td><td><img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"></td><td>(?:<form><input type="text" value=")?(\d+)(?:" size="8" name="r" class=text style="text-align:center;">)?</td><td>(?:<INPUT type="text" value=")?([0-9:]+)!) {
      my $sl=$1+($2/250);
      push(@science, [$sci,$sl, int($4), $5]);
   }
}
$d->{sciencelevel}=\@science;

if(m{<tr align=center bgcolor='#206060'><td><a href=/0/Glossary[^>]+>([^<]+)</a>}) {
   $d->{currentscience}=$1;
}

if(m{id=14>Culture</a> </td><td>(\d+)</td><td><img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="\d+"></td><td>(?:<form><input type="text" value=")?(\d+)(?:" size="8" name="r" class=text style="text-align:center;">)?</td><td>(?:<INPUT type="text" value=")?([0-9:]+)}) {
   my $cl=$1+$2/250;
   $d->{culturelevel}=[$cl, int($3), $4];

}

1;
