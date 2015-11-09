package brownie::awauth;
use strict;
use apacheconst;
use awstandard;
use brownie::testauth;

sub handler {
  my $r = shift;
  $r->headers_in->unset("awuser");
  $r->headers_in->unset("awpid");
  my $ip=$r->connection()->client_ip();
  if(awstandard::isproxy($ip) && (my $xff=$r->headers_in->{"X-Forwarded-For"})) { # this is for cgi-proxy auth
	$xff=~s/^::ffff://;
	$ip=$xff;
	$ip=~s/.*,\s*//;
  }
  $r->headers_in->set("awip", $ip);
  if($r->uri=~m%^/cgi-bin/(?:modperl/|nphperl/)?public/%) {
    $r->user("guest");
    return OK;
  }
#  require brownie::testauth;
  return brownie::testauth::test_auth($r);
#  my $headers_in=$r->headers_in;
#  my $cookies=$$headers_in{Cookie};
# if($cookies=~m/user=greenbird/) { $r->user("af"); return OK; }
#  my($res, $sent_pw) = $r->get_basic_auth_pw;
#  return $res if $res != OK; 

#  my $user = $r->user;
#  unless($user and $sent_pw) {
#      $r->note_basic_auth_failure;
#      $r->log_reason("Both a username and password must be provided", $r->filename);
#      return AUTH_REQUIRED;
#  }
#  return DECLINED;
}

1;
