package brownie::common;
use strict;
use apacheconst;

sub handler {
   my ($r, $handler) = @_;
	my $u=$r->unparsed_uri;
   if($r->uri =~ m{^/(?:cgi-bin/|code/|.well-known/|gbt/|manual)}) {
      return DECLINED;
   }
   # we handle this request
   $r->handler("perl-script");
   $r->set_handlers(PerlHandler => $handler);
   return OK;
}

1;
