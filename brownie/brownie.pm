package brownie::brownie;
use strict;
use apacheconst;
#use vars qw(@ISA $VERSION);
use LWP::UserAgent ();
use LWP::ConnCache;
#use Apache::RequestIO ();
#use Apache::RequestRec ();
#use Apache::RequestUtil;
#use Apache::ServerUtil;
#use Apache::Response;
#use Apache::URI;
#use ModPerl::MethodLookup;
#BEGIN {$VERSION = '1.02';}
use brownie::process;

#@ISA = qw(LWP::UserAgent);
#our $UA = __PACKAGE__->new(requests_redirectable=>[], parse_head=>0, timeout=>9);
# we need only one simultaneous connection per apache process (who forks)
#$UA->conn_cache(LWP::ConnCache->new( total_capacity=>1 ));
#$UA->agent(join ("/", __PACKAGE__, $VERSION)." (greenbird's alliance proxy)");

#our $phase=0;

sub handler {
   my ($r) = @_;
#   return DECLINED unless $r->proxyreq; # didnt work as mod_proxy sets proxyreq and steals request then
   return DECLINED unless $r->unparsed_uri=~m%^http://%;
	if($r->uri =~ m{^/(?:cgi-bin/|code/|.well-known/|manual)}) {
		return DECLINED;
	}
#   $r->proxyreq(2);
   # we handle this request
   $r->handler("perl-script");
   $r->set_handlers(PerlHandler => \&proxy_handler);
#   $r->push_handlers(PerlHandler => \&proxy_handler);
#diag time()." a ".$phase++." ".$r->method." ".$r->uri." ".$r->filename." ".$r->unparsed_uri." \n";
   return OK;
}

sub proxy_handler {
   my($r) = @_;
#   diag time()." x ".$phase++." ".$r->method." ".$r->uri." ".$r->filename." ".$r->unparsed_uri." \n";
   $r->status(200);
   $r->content_type("text/plain");
#   $r->print($r->method." ".$r->uri."\ntesting successful\n");
   $r->uri($r->unparsed_uri);
   my $result=brownie::process::process($r, "brownie");
   if($result) {
      $r->print($$result);
   }
	$_=undef; # clear private data
#   print "errors: $@" if $@;
   # done processing
   return OK;
}

1;
