use strict;
use awparser;
use awstandard;

my @news;
foreach my $nline (m{<tr>\s*(.+?)</td>\s*</tr>}gs) {
   my $isnew=tobool($nline=~m/class="incoming"/);
#   bgcolor='#101010'
   $nline=~m{>(\d+:\d+:\d+ - [A-Z][a-z][a-z] \d\d)</td>\s*<td[^>]*>(.*)};
   my $message=$2;
	if($isnew) {
		require parse::libincoming;
		my $inco=parse::libincoming::parse_incoming($nline);
		push(@{$d->{incoming}}, $inco) if $inco;
	}
   push(@news, {"new"=>$isnew, "time"=>parseawdate($1), "message"=>$message,
#         orig=>$nline
         });
}
foreach my $m ("Next", "Previous") {
   my $n=lc($m);
   if(m{\?p=\d+" accesskey=".">$m</a></li>}) {
         $d->{$n}=1;
   } else {$d->{$n}=0; }
}


$d->{news}=\@news;

2;
