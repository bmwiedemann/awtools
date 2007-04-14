use strict;
package mangle::login;
use DBAccess;
use awinput;

my $session=awstandard::cookie2session(${$::options{headers}}{Cookie});
my $name;
my $pid;
foreach my $x (@{$::options{headers_out}}) {
   next if $$x[0] ne "Set-Cookie";
   my $c=$$x[1];
   if($c=~m/PHPSESSID=([0-9a-f]{32})/) {
      $session=$1;
   }
   if($c=~m/login=(\d+)/) { # we can trust this as AW sent the headers
      $pid=$1;
      $name=awinput::playerid2namem($pid);
   }
}
if($session && $name) {
   my $time=time();
   my $sth=$dbh->prepare_cached("UPDATE `usersession` SET `nclick` = '0', `auth` = 1, `ip` = ?, `lastclick` = ?, name = ?, pid = ? WHERE `sessionid` = ?");
   my $res=$sth->execute($::options{ip}, $time, $name, $pid, $session);
   if($res eq "0E0") {
      my $sth=$dbh->prepare_cached("INSERT INTO `usersession` VALUES ( ?, ?, ?, 0, ?, ?, ?, 1);");
      $sth->execute($session, $pid, $name, $time, $time, $::options{ip});
   }
}
#$_.=" test $sess $name";

1;
