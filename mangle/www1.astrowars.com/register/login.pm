use strict;
package mangle::login;
use DBAccess;
use awinput;

my $session=awstandard::cookie2session(${$::options{headers}}{Cookie});
my $name;
foreach my $x (@{$::options{headers_out}}) {
   next if $$x[0] ne "Set-Cookie";
   my $c=$$x[1];
   if($c=~m/PHPSESSID=([0-9a-f]{32})/) {
      $session=$1;
   }
   if($c=~m/login=(\d+)/) {
      $name=awinput::playerid2name($1);
   }
}
if($session && $name) {
   my $time=time();
   my $res=$dbh->do("UPDATE `usersession` SET `nclick` = '0', `auth` = 1, `ip` ='$::options{ip}', `lastclick` = '$time' 
         WHERE `sessionid` = ".$dbh->quote($session));
   if($res eq "0E0") {
      my $sth=$dbh->prepare_cached("INSERT INTO `usersession` VALUES ( ?, ?, 0, ?, ?, ?, 1);");
      $sth->execute($session, $name, $time, $time, $::options{ip});
   }
}
#$_.=" test $sess $name";

1;
