# find timezone settings

my $pid=playername2id($::options{name});
if(!$pid) {print "user not found<br>\n";return 1}

if(m!Time Difference</a> \(-12 to \+11\) <br><small>server time - \d+:\d+ / your local time - \d+:\d+</small>\s*</td><td>\s*<input type="text" name="zeitdifferenz" size="8" class=text value="([-+0-9]+)"!) {
   my $tz=$1;
   print "found timezone $tz\n";

   use DBAccess;
   use Tie::DBI;
   my %pp;
   tie %pp,'Tie::DBI',$dbh,'playerprefs','pid',{CLOBBER=>1};
   my $h=$pp{$pid}||{customhtml=>"", storeir=>0};
   $h->{tz}=$tz;
   $pp{$pid}=$h;
}

1;
