use strict;
use awparser;
use awstandard;

my @news;
foreach my $nline (m{<tr valign="top">(.+?)</td></tr>}g) {
   my $isnew=tobool($nline!~m/bgcolor='#404040'/);
#   bgcolor='#101010'
   $nline=~m{>(\d+:\d+:\d+ - [A-Z][a-z][a-z] \d\d)</td><td[^>]*>(.*)};
   my $message=$2;
   push(@news, {"new"=>$isnew, "time"=>parseawdate($1), "message"=>$message,
#         orig=>$nline
         });
}
foreach my $m ("Next", "Previous") {
   my $n=lc($m);
   if(m{<td><a href="/0/News//\?p=\d+">$m</a></td>}) {
         $d->{$n}=1;
   } else {$d->{$n}=0; }
}

$d->{news}=\@news;

2;
