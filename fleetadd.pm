package fleetadd;
use strict;
use DBAccess;

# input $type: status of fleet (1=landed on own planet 0=landed on other planet 2=flying incoming 3=flying own fleet)
sub dbfleetaddmysql { my($sid,$pid,$plid,$name,$time,$type,$fleet, $tz, $screen)=@_;
   my $sidpid=awinput::sidpid22sidpid3m($sid,$pid);
   my $ret=0;
   my $now=time();
   my $alli=$ENV{REMOTE_USER};
   return if(!$alli || ($time && $time<$now-3600*24) || !$plid);
   my $status=$type||0; # use $type and $time
   $time||=0;
   $fleet->[1]||=0; # incomings have no info about CLS, but we dont want NULL/undef values in DB so far
   my $cv=awstandard::fleet2cv($fleet);
   my $xcv=awinput::estimate_xcv($plid,$cv);
   my $fleetmatch="";
   my $n=0;
   my $ownermatch="";
   foreach my $type (qw(trn cls ds cs bs)) {
#      next if($$fleet[1]==0 and (($awinput::fleetscreen&~2)==0) and ($type eq "cls")); # buggy: creates dups
      $fleetmatch.=" AND `$type` = '$$fleet[$n++]' ";
   }
# who was sieging is now outdated:
   my $ownerset="";
   my $xcvset=", `xcv` = ? ";
   if(!$time) {
      my $result=$dbh->do("UPDATE `fleets` SET `iscurrent` = 0 WHERE `alli` = '$alli' AND `sidpid` = '$sidpid' AND `eta` = 0");
      if($plid>2) {
         # add owner info when sieging friendly planets
         $ownermatch=" OR `owner` <= 2";
         $ownerset=", `owner` = ? ";
      } else {
         $ownermatch=" OR `owner` > 2";
         $xcvset="";
      }
   }
   if($status==2 and $cv==0 and $time and $fleet->[0]==0 and $fleet->[1]==0) {
      return; # do not add CLS-only incoming twice
   }
# update fleets that are still there...
   my $query="UPDATE `fleets` SET `iscurrent` = 1, `lastseen` = ?$xcvset$ownerset
         WHERE (`owner` = ? $ownermatch) AND `alli` = ? AND `sidpid` = ? AND `eta` = ? $fleetmatch LIMIT 2;";
#   awstandard::awdiag("scr:$awinput::fleetscreen".$query);
   my $sth=$dbh->prepare_cached($query);
   my $result=$sth->execute($now, ($xcvset?$xcv :()),($ownerset?$plid :()), $plid, $alli, $sidpid, $time);
   if($result eq "0E0") {
      # make sure it really is a new fleet as feeding a fleet twice in the same second will also result in 0 affected rows
      my $sth=$dbh->prepare_cached("SELECT `fid` from `fleets` WHERE (`owner` = ? OR `owner` <= 2) AND `alli` = ? AND `sidpid` = ? AND `eta` = ? $fleetmatch LIMIT 1");
      my $res=$dbh->selectall_arrayref($sth, {}, $plid, $alli, $sidpid, $time);
      if($$res[0]) {
         return
      }
      $sth=$dbh->prepare_cached("INSERT INTO `fleets` VALUES ('', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, '');");
      $sth->execute($alli, $status, $sidpid, $plid, $time, $now, $now, @$fleet, $cv, $xcv);
      $ret=1;
   }
   return $ret;
}

1;
