package awlogins;

use warnings;
use strict;
use DBAccess2;
use awsql;
use awstandard; # for awmax
use awinput;


sub add_login($$@) {
   my($alli,$pid, $newlogin)=@_;
#   my $alli=$ENV{REMOTE_USER};# "rats";
#   my $pid=49545;
#   my $newlogin=[100,time(), 123, 61];
   return unless $alli and $pid and $newlogin;
   my @l2=@$newlogin;
   my($loginn, $logintime, $loginidle, $loginacc)=@l2;
   my $loginid;
   my $dbh=get_dbh;
   my $sth;
   if(is_startofround()) {
      my $sth=$dbh->prepare("DELETE FROM `logins` WHERE `alli`=? AND `pid`=? AND n>?");
      $sth->execute($alli, $pid, $loginn);
   }

# fetch previous login entry
   if($loginacc>=86398) { # 86k for premium idle entry accuracy
      my @l0n=get_one_row("SELECT logins.* FROM logins,
       (
        SELECT `alli`,`pid`,MAX(`n`) AS maxn
        FROM `logins` WHERE `alli` = ? AND `pid` = ?
        GROUP BY `alli`,`pid`
       ) AS m WHERE m.maxn=n AND m.alli=logins.alli AND m.pid=logins.pid
       ", [$alli,$pid]);
      my @l0=@l0n[3..6];
      if(@l0 && $l0[0]) {
         my $diff=$l2[1]-$l2[3]-($l0[1]+$l0[2]);
         if($diff<0) {$loginacc=$l2[3]=awmax(1, $l2[3]+$diff)}
      }
   }
# get old entry with same login-id for merge:
   my ($allimatch, $amvars)=get_alli_match2($alli,4);
   my @l1n=get_one_row("SELECT `logins`.* FROM `logins`, `toolsaccess`
         WHERE $allimatch AND `pid` = ? AND `n` = ? ORDER BY `lid` DESC LIMIT 1
         ", [@$amvars,$pid,$loginn]);
   if(@l1n && $l1n[0]) {
      my @l1=@l1n[3..6];
      my @l3=@l1;
      # adjust start+idle times
      if($l2[1]<$l1[1]) {$l3[1]=$l2[1]; $l3[3]-=$l1[1]-$l2[1] }
      if($l2[1]+$l2[2] > $l1[1]+$l1[2]) {
         $l3[2]=$l2[1]+$l2[2]-$l3[1];
         my $maxerr=$l2[3]-($l2[1]-$l1[1]);
         if($maxerr>0 && $l3[3]>$maxerr) {$l3[3]=$maxerr}
      }
      if($l3[1]<$l1[1]) {
         my $tdiff=$l3[1]+$l3[2]-($l1[1]+$l1[2]);
         if($tdiff<$l3[3]) { $l3[3]=$tdiff }
      }
      
#my $diff=abs($l2[1]-$l1[1]);
#			print "debug: @l1 + @l2 -> @l3";
#			if($diff<$l2[3]) { $add=0; }
      @l2=@l3;
#      $loginid=$l1n[0];
   }
# write new or merged entry to DB:
   $sth=$dbh->prepare("REPLACE INTO `logins` VALUES ('',?,?,?,?,?,?)");
   $sth->execute($alli, $pid, @l2);
   return 1;
}

sub get_logins($$)
{ my($alli,$pid)=@_;
   my $dbh=get_dbh;
   my ($allimatch, $amvars)=get_alli_match2($alli,4);
   my $sth=$dbh->prepare("SELECT `n`, `time`, `idle`, `fuzz`
         FROM `logins`,`toolsaccess` WHERE $allimatch AND `pid` = ?");
   return $dbh->selectall_arrayref($sth,{}, @$amvars, $pid);
}

1;
