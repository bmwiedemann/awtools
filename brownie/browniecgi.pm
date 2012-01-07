package brownie::browniecgi;
use strict;
use apacheconst;
use vars qw(@ISA $VERSION);
use LWP::UserAgent ();
use LWP::ConnCache;
#use Apache::RequestIO ();
#use Apache::RequestRec ();
#use Apache::RequestUtil;
#use Apache::ServerUtil;
#use Apache::Response;
#use Apache::URI;
#use ModPerl::MethodLookup;
use brownie::process;
use awstandard;
my $desthost=$awstandard::server;#"www1.astrowars.com";
my $wwwdesthost=$awstandard::awforumserver;#"www.astrowars.com";
my $destdomain="astrowars.com";

sub handler {
   my ($r) = @_;
#   return DECLINED unless $r->unparsed_uri=~m%^http://%;
   # we handle this request
   $r->handler("perl-script");
   $r->set_handlers(PerlHandler => \&proxy_handler);
   return OK;
}

sub proxy_handler {
   my($r) = @_;
   $r->status(200);
   $r->content_type("text/plain");
   my $hi=$r->headers_in();
   my $host=$hi->get("Host");
   my $ourhost="aw21.zq1.de";
   my $wwwourhost="www.$ourhost";
   my $rsaourhost="rsa.$ourhost";
	my $rsadesthost="forum.rebelstudentalliance.co.uk";
# autodetect $ourhost value from input headers
   if($host=~/^www\.a/) { # matches $wwwourhost
      $wwwourhost=$host;
   	$r->uri("http://".$wwwdesthost.$r->unparsed_uri);
   } elsif($host eq $rsaourhost) {
		$r->uri("http://$rsadesthost".$r->unparsed_uri);
	} else {
      $ourhost=$host;
   	$r->uri("http://".$desthost.$r->unparsed_uri);
   }
   my $result=brownie::process::process($r, "brownie21");

# filter headers_out as with ProxyPassReverse
   my $h=$r->headers_out();
   foreach my $k (qw(Content-Location Location URI)) {
      my $l=$h->get($k);
      if($l && ( $l=~s!(http://)$desthost!$1$ourhost! || $l=~s!(http://)$wwwdesthost!$1$wwwourhost! || $l=~s!(http://)$rsadesthost!$1$rsaourhost!)) {
         $h->set($k,$l);
      }
   }
# cookie reverse modification
   for my $k ("Set-Cookie") {
      my @l=$h->get($k);
      foreach my $cookie (@l) {
         if($cookie=~s/$desthost/$ourhost/ || $cookie=~s/$wwwdesthost/$wwwourhost/ || $cookie=~s/domain=$destdomain/host=$ourhost/ || $cookie=~s/$rsadesthost/$rsaourhost/) {
            $h->add($k, $cookie);
         }
      }
   }

	if($result) {
		# do some extra post-processing in CGI-mode
		$$result=~s!(http-equiv="refresh"[^>]*url=http://)$desthost!$1$ourhost!i;
		$$result=~s!(http-equiv="refresh"[^>]*url=http://)$wwwdesthost!$1$wwwourhost!i;
		$$result=~s!(<a[^>]* href="?http://)$desthost!$1$ourhost!gi;
		$$result=~s!(<a[^>]* href="?http://)$wwwdesthost!$1$wwwourhost!gi;
		$$result=~s!(<img[^>]* src="?http://)$desthost!$1$ourhost!gi;
      $$result=~s!(<form action="?http://)$desthost!$1$ourhost!gi;
		if(1) {
			$$result=~s!(http-equiv="refresh"[^>]*url=http://)$rsadesthost!$1$rsaourhost!i;
			$$result=~s!(<a[^>]* href="?http://)$rsadesthost!$1$rsaourhost!gi;
			$$result=~s!(<img[^>]* src="?http://)$rsadesthost!$1$rsaourhost!gi;
			$$result=~s!(<form action="?http://)$rsadesthost!$1$rsaourhost!gi;
		}
		$r->print($$result);
#		$r->print("\n\nD$desthost O$ourhost\n");
	}
	$_=undef; # clear private data
   return OK;
}

1;
