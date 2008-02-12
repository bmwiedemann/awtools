use Tie::DBI;
#use strict;
use awstandard;
use awinput;

sub feed_profile() {
print "profile feed\n";
my $data=getparsed(\%::options);

my $name=$data->{name};
my $opid=$data->{pid};
#m/<html><head><title>(\S*)/;
#my $name=$1;
#my $opid=playername2id($name);
print a({-href=>"relations?name=$name"},$name).br."\n";
my $pl=$data->{playerlevel};
my $pointsh=$data->{points};

if($pointsh && $opid) {
   my $points=$pointsh->{total};
   my $totalpop1=$pointsh->{"pop"};
#   use DB_File;
#   my %pointsdb;
#   tie(%pointsdb, "DB_File", "/home/bernhard/db/points.dbm") or print "\nerror accessing DB\n";
   
   print "Points: $points $pl\n";
#   $pointsdb{$name}=$points;

   my %h;
   my $now=time();
   my $time=$now-3600*9;
   $dbh->do("DELETE FROM cdcv WHERE pid = $opid"); # delete old entries
   tie(%h,'Tie::DBI',$dbh,'cdcv','sidpid',{CLOBBER=>1});
   my $totalpop=0;
   foreach my $p (@{$data->{planet}}) {
      my($pop,$cv)=($p->{"pop"}, $p->{cv});
      my($sidpid)=sidpid22sidpid3m($p->{sid},$p->{pid});
#         awdiag("test3 $n $sid#$pid=$sidpid $pop $cv");
      $h{$sidpid}={time=>$now, cv=>$cv, pop=>$pop, pid=>$opid};
      $totalpop+=$pop;
   }
   untie(%h);
   if($totalpop1 != $totalpop) {
      print STDERR "profile feed pop sum mismatch: '$totalpop1'!='$totalpop'\n";
   } else {
      $dbh->do("DELETE FROM cdlive WHERE pid = $opid"); # delete old entries
      tie(%h,'Tie::DBI',$dbh,'cdlive','pid',{CLOBBER=>1});
      $h{$opid}={time=>$now, points=>$points, pl=>$pl, totalpop=>$totalpop};
      untie %h;
   }
}
   # autodetect and add trades:
   $opid+=0;
   my @a=(m%<a href=/about/playerprofile\.php\?id=(\d+)>[^<]+</a><br>%g);
   awinput::add_trades($opid,\@a);

   if((my $tr=$data->{traderevenue})) {
      $tr+=0;
      $dbh->do("REPLACE INTO `tradelive` VALUES ($opid,$tr)");
   }
}

1;
