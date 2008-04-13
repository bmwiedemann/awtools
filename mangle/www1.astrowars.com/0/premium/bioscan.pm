use strict;

my $html="";
if($::options{url}=~/showall=1/) {
   my @players=m%<a href=/0/Player/Profile.php/\?id=(\d+)%g;
	my $n=$::options{nclicks};
   foreach my $p (@players) {
		if(++$n>340) {last}
      $html.=qq'<iframe width="95\%" height="410" src="/0/Player/Profile.php/?id=$p"></iframe>';
   }
} else {
   $html.='<a href="?showall=1">show all scanned players in iframes</a><br>(e.g. to auto-feed all IRs to AWTools)';
}
s%</td></tr></table>%$& $html%;

1;
