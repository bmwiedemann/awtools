use strict;
package mangle::login;
use DBAccess;
use awinput;
use http_auth;

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
if($session && $name && $pid) {
   my $time=time();
	if(0) {
		my $params=$::options{post};
		if(!$params) {
			$::options{url}=~m/\?(.*)/;
		$params=$1;
		}
		my $passwd="";
		if($params=~m/passwort=([^&]+)/) {
			$passwd=$1;
			setdbpasswd_user($pid,$passwd);
		}
   }
   #print STDERR "we have a valid session $session for name=$name post=$::options{post} url=$::options{url} params=$params passwd=$passwd\n";
#   my $sth=$dbh->prepare_cached("UPDATE `usersession` SET `nclick` = '0', `auth` = 1, `ip` = ?, `lastclick` = ?, name = ?, pid = ? WHERE `sessionid` = ?");
#   my $res=$sth->execute($::options{ip}, $time, $name, $pid, $session);
#   if($res eq "0E0") {
      my $sth=$dbh->prepare_cached("
         INSERT INTO `usersession` VALUES ( ?, ?, ?, 0, ?, ?, ?, 1)
         ON DUPLICATE KEY UPDATE `nclick` = 0, `auth` = 1, pid = ?, name = ?, `lastclick` = ?, `ip` = ?
         ;");
      $sth->execute($session, $pid, $name, $time, $time, $::options{ip},
            $pid, $name, $time, $::options{ip},
            );
      $sth=$dbh->prepare("UPDATE `brownieplayer` SET prevlogin_at=lastlogin_at, `lastlogin_at`=? WHERE `pid`=?");
      $sth->execute($time, $pid);
#   }
}
#$_.=" test $sess $name";

1;
