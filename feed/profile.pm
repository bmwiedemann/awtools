use Tie::DBI;
use awstandard;
use awinput;

sub feed_profile() {
print "profile feed\n";

m/<html><head><title>(\S*)/;
my $name=$1;
my $opid=playername2id($name);
print a({-href=>"relations?name=$name"},$name).br."\n";

if(m!>Points: (\d+)</td>!) {
   my $points=$1;
   use DB_File;
   my %pointsdb;
   tie(%pointsdb, "DB_File", "/home/bernhard/db/points.dbm") or print "\nerror accessing DB\n";
   
   print "Points: $points\n";
   $pointsdb{$name}=$points;

   my %h;
   tie(%h,'Tie::DBI',$dbh,'cdcv','sidpid',{CLOBBER=>3});
   my $now=time();
   foreach my $n (1..40) {
      if(my($sid,$pid,$pop,$cv)=(m%<tr bgcolor="#303030" align=center><td>$n</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>%)) {
         my($sidpid)=sidpid22sidpid3m($sid,$pid);
#         awdiag("test3 $n $sid#$pid=$sidpid $pop $cv");
         $h{$sidpid}={time=>$now, cv=>$cv};
         
      }
   }
   untie(%h);
}
   # autodetect trades:
   $opid+=0;
   my @a=(m%<a href=/about/playerprofile\.php\?id=(\d+)>[^<]+</a><br>%g);
   tie(%h,'Tie::DBI',$dbh,'trades','pid1',{CLOBBER=>3});
   my $old=$dbh->selectall_arrayref("SELECT pid1,pid2 FROM `trades` WHERE `pid1` = $opid OR `pid2` = $opid");
   my %oldmap;
   if($old) {
      foreach my $row (@$old) {
         my @a=@$row;
         $oldmap{$a[0]}=$oldmap{$a[1]}=1;
      }
   }
   foreach my $xpid (@a) {
      next if($oldmap{$xpid}); # do not re-add existing entries
      my $pid1=awmax($xpid,$opid);
      my $pid2=awmin($xpid,$opid);
      eval(' $h{$pid1}={pid2=>$pid2, time=>time()}; 
            ');
#$h{$xpid}={pid2=>$opid, time=>time()}; 
   }
#   awdiag("$opid @a : $old");
   untie(%h);
}

1;
