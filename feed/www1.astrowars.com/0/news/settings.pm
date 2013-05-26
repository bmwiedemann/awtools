use awstandard;
# find timezone settings

my $data=getparsed(\%::options);
my $pid=playername2idm($::options{name});
if(!$pid) {print "user not found<br>\n";return 1}

my $tz=$data->{zeitdifferenz};
if(defined($tz)) {
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
