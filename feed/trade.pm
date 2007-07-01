use DBAccess2;

my($ad)=m!href=/0/Glossary//\?id=48>Astro Dollars</a></td><td align=center>\$([-0-9,.]+)</b></td>!;
my($tr)=m!Trade Revenue</td><td>(\d+)%</td></tr>!;
my($sus)=m!href=/0/Glossary//\?id=33>Supply Units</a></td><td align=center>(\d+)/\d+</b></td></tr>!;
#my($arti)=m!<tr bgcolor='#206060'><td>&nbsp;[a-zA-Z]+ [1-3]</td><td align=center>1</td></tr>!;

if($::options{pid} && defined($ad)) {
   my $dbh=get_dbh();
   $ad=~s/\.//g;
   $ad=~s/,/./;
   my $sth=$dbh->prepare("UPDATE `internalintel` SET `tr`=?, `ad`=?, `sus`=? WHERE `alli`=? AND `pid`=?");
   $sth->execute($tr, $ad, $sus, $ENV{REMOTE_USER}, $::options{pid});
}

1;
