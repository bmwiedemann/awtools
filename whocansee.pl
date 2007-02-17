#!/usr/bin/perl -w

use strict;
use DBAccess;
use awstandard;
use awinput;
my $sysid = shift @ARGV;
$ENV{REMOTE_USER} = shift @ARGV;
my $wantbio25 = shift @ARGV;
#if(!$ENV{REMOTE_USER}) { $ENV{REMOTE_USER}="idle"; }
awinput_init();

my @sysxy = systemid2coord($sysid);#(59,-12);
my $delta = 25; # for Bio25

my (@minxy,@maxxy);
@minxy=@maxxy=@sysxy;
foreach(@minxy){$_-=$delta}
foreach(@maxxy){$_+=$delta}

my $allplayers=$DBAccess::dbh->selectall_arrayref( qq(
SELECT  x,y,player.name,pid,science
FROM  `player`,`starmap` 
WHERE 
 `home_id` = starmap.`sid` AND starmap.x >= $minxy[0] AND starmap.y >= $minxy[1] AND starmap.x <= $maxxy[0] AND starmap.y <= $maxxy[1]
   ));

foreach(@$allplayers) {
   my($ex,$ey,$ename,$epid,$esl)=@$_;
   my @rel=getrelation($ename);
   next if(!$rel[2]);
   my @sci=relation2science($rel[2]);
   $sci[0]||=0;
   if($sci[0]>100){shift(@sci)}
   my $bio=$sci[0]||0;
   if($bio<25 || !$wantbio25) {
      next if(abs($ex-$sysxy[0])*2>$bio);
      next if(abs($ey-$sysxy[1])*2>$bio);
   }
#   next if($rel[0]<9);
#print "@$_\n";
#next if $member{$epid};
   print (join("\t", $ex, $ey, $ename, $epid, $esl, $bio, $rel[0])."\n");
}

