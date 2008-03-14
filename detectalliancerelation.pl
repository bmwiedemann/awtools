#!/usr/bin/perl -w
# this code is Copyright Bernhard M. Wiedemann and licensed under GNU GPL
use strict;
use awinput;
use DBAccess2;
awinput_init(1);

if(scalar keys %awinput::alliances<10) {exit 0}
my %relation;
my %nsystems;
my %conq;
my %killedpop;
my %battlecv;
my %battlenum;
my %killedcv;
my $maxkilledcv=0;
my %bonuspoints;

sub max($$) {$_[0]>$_[1]?$_[0]:$_[1]}

#print STDERR "importing old data...\n";
close STDERR;
my @olddata;
my @oldpopdata;
for my $day (0..7) {
   my @t=localtime(time()-3600*24*$day);
   my ($d,$m,$y)=(sprintf("%.2i",$t[3]),sprintf("%.2i",$t[4]+1), $t[5]+1900);
   if($day) {
      my %oldday;
      my %olddaypop;
      my $f="www1.astrowars.com/export/history/all$d-$m-$y.tar.bz2";
      if(not -e $f) {exit 1} # dont work at start of round
      open(F, "tar -Oxjf $f planets.csv |") or next;
      my $dummy=<F>;
      while(<F>) {
         next if m/^\s*$/;
         my @a=split("\t");
         my $sidpid="$a[0]#$a[1]";
         $oldday{$sidpid}=$a[4];
         $olddaypop{$sidpid}=$a[2];
#		print "$a[0]#$a[1] $a[4]\n";
      }
      push @olddata, \%oldday;
      push @oldpopdata, \%olddaypop;
   }
   open(F, "tar -Oxjf www1.astrowars.com/export/history/all$d-$m-$y.tar.bz2 battles.csv |") or next;
   my $dummy=<F>;
   my $n=0;
   while(<F>) {
      my(undef, $cv_def, $cv_att, $att_id, $def_id, $win_id)=split("\t");
      if($def_id<=2) {next}
      my $aid1=playerid2alliance($att_id);
      my $aid2=playerid2alliance($def_id);
      if(!$aid1 || !$aid2) {next}
      my $key="$aid1,$aid2";
      if($aid1>$aid2) {$key="$aid2,$aid1";}
      $battlecv{$key}+=$cv_att+$cv_def;
      $battlenum{$key}++;
#$killedcv{$key}+=$win_id==$def_id?$cv_att : $cv_def;
      my $killedcv;
      if($win_id==$def_id) { $killedcv{"$aid1,$aid2"}+=$cv_att; $killedcv=$cv_att }
      else { $killedcv{"$aid2,$aid1"}+=$cv_def; $killedcv=$cv_def }
      if($killedcv>$maxkilledcv) {$maxkilledcv=$killedcv}
#print "$key $battlecv{$key} $killedcv{$key} $cv_def, $cv_att, $att_id, $def_id, $win_id\n";
#      if($n++>10) {exit 0;last;}
   }
}
#print STDERR "scanning systems...\n";

for my $sid (1..6000) {
 my %allis=();
 my $level=systemid2level($sid);
 my $minpop=100;
 for my $plid (1..12) {
	my $p=getplanet($sid, $plid);
	my $o=planet2owner($p);
	my $pop=planet2opop($p);
	if(!$o || $o<=2) {next}
	if($pop<$minpop) {$minpop=$pop}
	my $aid=playerid2alliance($o);
	if(!$aid) {next}
	if($awinput::alliances{$aid}{points}<270 && allianceid2members($aid)<8) {next}
	$allis{$aid}++;
	my $sidpid="$sid#$plid";
	my $n=0;
	foreach my $oldowner (@olddata) {
		my $o2=$$oldowner{$sidpid};
		last unless $o2 && $o2>2;
		if($o2!=$o) {
			my $aid2=playerid2alliance($o2);
			last unless $aid2;
			my $rel="$aid,$aid2";
#			if($aid==82 && $aid2==62) {print "$sidpid ${$oldpopdata[$n]}{$sidpid}\n"}
			$conq{$rel}++;
			$killedpop{$rel}+=${$oldpopdata[$n]}{$sidpid};
			$relation{$rel}+=0; # force entry
			$nsystems{$rel}+=0;
#print "$sidpid $aid2->$aid\n";
			last;
		}
		$n++;
	}
 }
 foreach my $a1 (keys %allis) {
  foreach my $a2 (keys %allis) {
	next if $a1==$a2;
	my $rel="$a1,$a2";
#	if($a1==13 && $a2==61) {print "$sid\n"}
	$relation{$rel}+=$minpop;#*$allis{$a1}*$allis{$a2};
	$nsystems{$rel}++;
  }
 }
}

my $dbh=get_dbh();
if($dbh) {
my $intertrades=$dbh->selectall_arrayref("
SELECT p1.alliance, p2.alliance, COUNT( p1.alliance )
FROM `alltrades` , player AS p1, player AS p2
WHERE pid1 = p1.pid
AND pid2 = p2.pid
AND p1.alliance !=0
AND p2.alliance !=0
AND p1.alliance < p2.alliance
GROUP BY p1.alliance, p2.alliance
");
   foreach my $a (@$intertrades) {
      my ($a1,$a2,$n)=@$a;
      my $bonus=0.7*$n*1.1**$n;
#     print "debug: $a1 x $a2 x $n $bonus\n";
      $bonuspoints{"$a1,$a2"}+=$bonus;
      $bonuspoints{"$a2,$a1"}+=$bonus;
   }
}

#sub sortfunc { return $relation{$b}<=>$relation{$a} }
sub sortfunc { return $nsystems{$b}<=>$nsystems{$a} || $relation{$b}<=>$relation{$a}}

#print STDERR "printing results...\n";

foreach my $rel (sort sortfunc keys %relation) {
	my @a=split(",",$rel);
	if($a[0]>=$a[1]) {next}
	my $rrel="$a[1],$a[0]"; # reverse relation
	my $conq1=$conq{$rel}||0;
	my $conq2=$conq{$rrel}||0;
	my $conq=$conq1+$conq2;
	my $pop1=$killedpop{$rel}||0;
	my $pop2=$killedpop{$rrel}||0;
	my $n=$nsystems{$rel}||4;
   my $battlecv=$battlecv{$rel}||0;
   my $battlenum=$battlenum{$rel}||0;
   my $killedcv=$killedcv{$rel}||0;
   my $killedcv2=$killedcv{$rrel}||0;
   my $bonusp=$bonuspoints{$rel}||0;
	$a[0]=allianceid2tag($a[0]);
	$a[1]=allianceid2tag($a[1]);
   my $cvpoints=1.5*max(0, $killedcv+$killedcv2-$maxkilledcv/2)/($maxkilledcv+1);
	my $f=sprintf "%.4f",$relation{$rel}/$n-3-$conq/($n**0.25) -$cvpoints+$bonusp; # friendship rating
   my $allis="$a[0] -- $a[1]; //";
   while(length($allis)<16) {$allis.="/"}
	print "$allis $relation{$rel} $nsystems{$rel} $conq1 $conq2 $pop1 $pop2 $killedcv2 $killedcv $battlecv $battlenum $f\n";
}
