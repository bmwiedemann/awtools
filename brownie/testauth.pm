package brownie::testauth;
use strict;
use apacheconst;
use DBAccess;
use awinput;
use http_auth;
use Apache2::Log; # for log_reason

sub test_auth { my($r)=@_;
	my $headers_in=$r->headers_in;
	my $conn=$r->connection();
	my $ip=$headers_in->{awip};
	my $cookies=$$headers_in{Cookie};
	if((my $session=awstandard::cookie2session($cookies))) {
		my $aref=get_one_rowref("SELECT `name`,`pid` from `usersession` WHERE `auth` = 1 AND `sessionid` = ? AND `ip` = ?", [$session, $ip]);
		if(my $a=$aref) {
			my $user=$$a[0];
			my $pid=$$a[1];
			$headers_in->set("awuser", $user);
			$headers_in->set("awpid", $pid);
			my $ruser=awinput::playerid2alli($pid);
			if($ruser) {
				$r->user($ruser);
				return OK;
			}
		}
	}
	my($res, $sent_pw) = $r->get_basic_auth_pw;
	#  print STDERR "auth test $res $sent_pw ", $r->user,"\n";
	return $res if $res != OK;
	my $user=$r->user;
	if(lc($user) eq "guest") {
		$r->user("guest");
		return OK;
	}
	# mysql per-user auth:
	my $reason="";
	my $pid=playername2idm($user);
	if($pid && checkdbpasswd_user($pid, $sent_pw, $reason)) {
		#  	print STDERR "user check OK for $user\n";
		# find alli/tag for him
		$headers_in->set("awuser", $user);
		$headers_in->set("awpid", $pid);
		my $ruser=awinput::playerid2alli($pid);
		if($ruser) {
			$r->user(lc($ruser));
		} else {
			$r->user("guest");
		}
		return OK;
	}
	if(!$pid) {$reason="player not found"}
	# mysql alli http_auth happens here
	if($user=~m/^[a-zA-Z]{1,4}$/ && checkdbpasswd($user, $sent_pw, $reason)) {
	#    print STDERR "mysql auth OK: $user $crypted $group\n";
		$r->user(lc($user));
		return OK;
	}

# reject as un-authorized (gives user the possibility to re-auth)
	$r->note_basic_auth_failure;
	if($user && $r->filename ne "/home/aw/cvs/awcalc/cgi-bin/logout") {
	   $r->log_reason("user '$user' by $ip: $reason", $r->filename);
	}
	return AUTH_REQUIRED;
}

1;
