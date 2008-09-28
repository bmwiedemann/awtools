#!/usr/bin/perl
use strict;
#$ENV{REMOTE_USER}="af";
exit 0 if $ENV{REMOTE_USER} eq "guest";

my $alli=$ENV{REMOTE_USER};
my @members;
use DBAccess2;
use awstandard;
use awinput;
awinput_init(1);
	my $dbh=get_dbh();
	my $sth=$dbh->prepare("
	 SELECT pid
	 FROM `relations`
	 WHERE `alli` = ?
	 AND STATUS >=8
	 UNION DISTINCT
	 SELECT pid
	 FROM player, alliances
	 WHERE alliance = aid
	 AND tag = ?
	");
	my $relation=$dbh->selectcol_arrayref($sth, {}, $alli,$alli);
   foreach my $pid (@$relation) {
		my $name=playerid2name($pid);
		my ($r,$s)=playerid2ir($pid);
		next if not $pid or not $s or not $s->[0];
		push(@members,[$name,$pid, $s->[1]]);
   }

#print @members,"\n";exit 0;
#require "input-mysql.pm";
my @coords=();
my %bio;
my @memberids;
my %member;
my $minsci=100;
my $scidiff=3;
my $AUdiff=20;
my $distmargin=1;
foreach my $e (@members) {
   my($name,$pid,$bio)=@$e;
   $member{$pid}=1;
   push(@memberids,$pid);
   my $sid=playerid2home($pid);
   my ($x,$y)=systemid2coord($sid);
   push(@coords,[$x,$y]);
   my $sl=$::player{$pid}{science};
   if(!$bio){$bio=4}#$sl}
   $bio{$pid}=$bio;
   if($bio<$minsci) {$minsci=$bio}
}
my (@minxy,@maxxy);
foreach(@coords) {
   #print "($$_[0],$$_[1])\n";
   for my $i (0..1) {
      if(!defined($minxy[$i]) || $$_[$i]<$minxy[$i]) { $minxy[$i]=$$_[$i] }
      if(!defined($maxxy[$i]) || $$_[$i]>$maxxy[$i]) { $maxxy[$i]=$$_[$i] }
   }
}
for my $i (0..1) {
   $minxy[$i]-=$AUdiff;
   $maxxy[$i]+=$AUdiff;
}
if(!defined($maxxy[0]) || $minsci>=100) {
   exit 0;
}
#print "@minxy , @maxxy";
$minsci+=$scidiff;
my $sth=$dbh->prepare(
      qq(
SELECT  x,y,player.name,pid,science
FROM  `player`,`starmap` 
WHERE science >= ?
AND `home_id` = starmap.`sid` AND starmap.x >= ? AND starmap.y >= ? AND starmap.x <= ? AND starmap.y <= ?
   ));
$|=1;
my $allplayers=$dbh->selectall_arrayref($sth, undef, $minsci, $minxy[0], $minxy[1], $maxxy[0], $maxxy[1]); 

#while(<>) { print eval; }

foreach(@$allplayers) {
   my($ex,$ey,$ename,$epid,$esl)=@$_;
#print "@$_\n";
   my @rel=getrelation($ename);
   if($rel[0]>5){next}
   next if $member{$epid};
   foreach my $pid (@memberids) {
      my $sl=$bio{$pid}; #$::player{$pid}{science};
      next if($esl<($sl+$scidiff));
      my $sid=playerid2home($pid);
      my ($x,$y)=systemid2coord($sid);
      my $dist=int($esl/2)+$distmargin;
      next if(abs($ex-$x)>$dist || abs($ey-$y)>$dist);
#print "$ename=$epid($esl) -> $pid($sl)\n";
      print join("\t",($ename, $epid, $esl, $pid, $sl))."\n";
   }
}

