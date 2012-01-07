#file:MyApache2/SecretResourceAuthz.pm
#------------------------------------
package brownie::awauthz;
use strict;
use warnings;

use Apache2::Access ();
use Apache2::RequestUtil ();
use apacheconst;
#use Apache::Const -compile => qw(OK HTTP_UNAUTHORIZED);

sub handler {
	my $r = shift;
	my $user = $r->user;
	if ($user) {
		 my ($section) = $r->uri =~ m|^/alli/(\w+)/|;
		 if (defined $section) {
			  return OK if $section eq $user;
		 } else {
			  return OK;
		 }
	}

	$r->note_basic_auth_failure;
	return AUTH_REQUIRED; # was Apache2::Const::HTTP_UNAUTHORIZED
}

1;
