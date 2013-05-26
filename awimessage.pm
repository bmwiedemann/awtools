#
# manage instant messages with brownie for AW
#
package awimessage;
use strict;
use warnings;
use DBAccess2;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(get_all_ims);

# input options hash
# input optional bit-combination: 1=recv 2=sent ; default 3
sub get_all_ims($;$)
{
   my $options=shift;
   my $dbh=get_dbh;
   my $what=shift||3;
   if($what&3==0) {return []}
   my @selstr=();
   if($what&1) {push @selstr," `recvpid` = ? "}
   if($what&2) {push @selstr," `sendpid` = ? "}
   my $selstr=join(" OR ", @selstr);
   my $sth=$dbh->prepare_cached("SELECT * FROM `imessage` WHERE $selstr ORDER BY `time`");
   my $res=$dbh->selectall_arrayref($sth, {}, ($what&1)?$$options{authpid}:(), ($what&2)?$$options{authpid}:());
   return $res;
}

sub delete(%)
{
   my $options=shift;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("DELETE FROM `imessage` WHERE `imid` = ? AND ( `recvpid` = ? OR `sendpid` = ?)");
   my $res=$sth->execute($$options{imid},$$options{authpid}, $$options{authpid});
   if($res==1) {
      print "deleted message $$options{imid}";
   } elsif($res eq "0E0") {
      print "message not found";
   }else {
      print "DB error $res?";
   }
}

# delete all received messages
sub delete_all_x(%)
{
   my $options=shift;
   my $dbh=get_dbh;
   my $what=($$options{action} eq 'delrecv'?'recvpid':'sendpid');
   my $sth=$dbh->prepare_cached("DELETE FROM `imessage` WHERE `$what` = ?");
   my $res=$sth->execute($$options{authpid});
   if($res > 0) {
      return "deleted $res messages";
   } elsif($res eq "0E0") {
      return "no messages found";
   }else {
      return "DB error $res?";
   }
}

sub send(%) {
   my $options=shift;
   $$options{msg}=~s/[<>]//g; # mini sanitize user input; #TODO: bbcode?
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("INSERT INTO `imessage` VALUES ('', ?, ?, ?, ?);");
   $sth->execute(time(),$$options{authpid},$$options{recv},$$options{msg});
   return " sent message to ".awinput::playerid2link($$options{recv});
}

sub get_recv_count($) { my($pid)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT count(imid) FROM `imessage` WHERE `recvpid` = ? GROUP BY recvpid");
   my $r=$dbh->selectall_arrayref($sth, {}, $pid);
   if($r && $r->[0]) {
      return $r->[0]->[0];
   }
   return;
}

1;
