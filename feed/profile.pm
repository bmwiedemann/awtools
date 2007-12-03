use Tie::DBI;
use awstandard;
use awinput;

sub feed_profile() {
print "profile feed\n";

m/<html><head><title>(\S*)/;
my $name=$1;
my $opid=playername2id($name);
print a({-href=>"relations?name=$name"},$name).br."\n";

my ($pl)=(m!>Playerlevel</td><td>(\d+)!);
if(m!>Points: (\d+)</td><td>(\d+)! && $opid) {
   my $points=$1;
   my $totalpop1=$2;
#   use DB_File;
#   my %pointsdb;
#   tie(%pointsdb, "DB_File", "/home/bernhard/db/points.dbm") or print "\nerror accessing DB\n";
   
   print "Points: $points $pl\n";
#   $pointsdb{$name}=$points;

   my %h;
   my $now=time();
   my $time=$now-3600*9;
   $dbh->do("DELETE FROM cdcv WHERE pid = $opid"); # delete old entries
   tie(%h,'Tie::DBI',$dbh,'cdcv','sidpid',{CLOBBER=>3});
   my $totalpop=0;
   foreach my $n (1..30) {
      if(my($sid,$pid,$pop,$cv)=(m%<tr bgcolor="#303030" align=center><td>$n</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>%)) {
         my($sidpid)=sidpid22sidpid3m($sid,$pid);
#         awdiag("test3 $n $sid#$pid=$sidpid $pop $cv");
         $h{$sidpid}={time=>$now, cv=>$cv, pop=>$pop, pid=>$opid};
         $totalpop+=$pop;
      }
   }
   untie(%h);
   if($totalpop1 != $totalpop) {
      print STDERR "profile feed pop sum mismatch: '$totalpop1'!='$totalpop'\n";
   }
   $dbh->do("DELETE FROM cdlive WHERE pid = $opid"); # delete old entries
   tie(%h,'Tie::DBI',$dbh,'cdlive','pid',{CLOBBER=>3});
   $h{$opid}={time=>$now, points=>$points, pl=>$pl, totalpop=>$totalpop};
   untie %h;
}
   # autodetect and add trades:
   $opid+=0;
   my @a=(m%<a href=/about/playerprofile\.php\?id=(\d+)>[^<]+</a><br>%g);
   awinput::add_trades($opid,\@a);

   if(m!>Trade Revenue</td><td bgcolor="?#202020"?>(\d+)%</td>!) {
      $dbh->do("REPLACE INTO `tradelive` VALUES ($opid,$1)");
   }
}

1;
