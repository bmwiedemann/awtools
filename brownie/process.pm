# this file was separated from brownie.pm 
# to allow changes taking effect without restarting apache

package brownie::process;
use strict;
use warnings;
use Socket;
use CGI;
use Time::HiRes qw(gettimeofday tv_interval); # for profiling
use awstandard;
use awinput;
use feed::dispatch;
use DBAccess;

our $VERSION="2.1";
our $debug=0;
our $ownid="1.1 ${bmwserver}";

our $UA = LWP::UserAgent->new(requests_redirectable=>[], parse_head=>0, timeout=>13);
# we need only one simultaneous connection per apache process (who forks)
$UA->conn_cache(LWP::ConnCache->new( total_capacity=>1 ));
$UA->agent(join ("/", "brownie", $VERSION)." (greenbird's alliance proxy)");


sub read_post($$) {
      my $r = shift;
      my $length=shift;
      if(!$length || $length<0){return}
      my $data;
      $r->read($data,$length);
#      my $data="test=28";
      return $data;
}

sub process($;$) {my ($r,$proxy)=@_;
   my $t0=[gettimeofday];
   my $uri=$r->uri;
   my $debuglog="";
# filter for wanted URLs (whitelisting)
   my $urimatch =  qr%^http://(?:\w*\.)?(?:lsmod\.de)|(?:astrowars\.com)|(?:rebelstudentalliance\.co\.uk)|(?:de\.wikipedia\.org)%;
   if($uri!~m%$urimatch%o)  {
      $r->status(403);
      $r->print("denied\n");
      return;
   }
   my $method = uc($r->method);

# pre-process
   my $filtereduri=$uri;
#   $filtereduri=~s/(Spend_Points.php\?p=\d+&i=\d+)&points=\d+&production=\w+$/$1/;

# prepare forwarding of request
   my $request = HTTP::Request->new($method, $filtereduri);
   my $headers_in = $r->headers_in;
   while(my($key,$val) = each %$headers_in) {
      next if($key eq "Host"); # do not override host header
      next if($key eq "Accept-Encoding");
      $request->header($key,$val);
   }
   my $c=$r->connection();
   my $ip=$c->client_ip();
   %::options=(); # make sure we wipe everything global from before
   my %options=qw(tz 0 name undefuser);
   $options{proxy}=$proxy||"unknown";
#   if($ip eq "141.20.") { $options{ip}=$ip="x"; }
# we do not want anonymous proxying, so add original IP
   if(!awstandard::isproxy($ip) or !(my $xff=$request->header("X-Forwarded-For")))
   #or $request->header("Via") ne "nph-proxy") 
   {
		my $nxff=awstandard::map_forward_ip($ip);
		$ENV{HTTP_AWIP}=$ip;
		$request->header("X-Forwarded-For6", $ip);
      $request->header("X-Forwarded-For", $nxff);
      $request->header("X-Forwarded-Host", $headers_in->{Host});
      $request->header("Via", $ownid);
   } else {
      # nph-brownie sends in full HTTP-requests from localhost but we want the original IP in here
      $request->header("Via", $ownid);
		$xff=~s/::ffff://; # clean IPv6-style IPv4 addrs from haproxy
		my $oxff=$xff;
		$xff=~s/.*,\s*//;
      $ENV{HTTP_AWIP}=$ENV{REMOTE_ADDR}=$ip=$xff;
		my $nxff=awstandard::map_forward_ip($xff);
		if($nxff ne $xff) {
			$request->header("X-Forwarded-For6", $oxff);
			$oxff=~s/$xff/$nxff/;
			#$ip=$nxff;
		}
		$request->header("X-Forwarded-For", $oxff);

#      if($ip eq "192.168.234.46") { $ENV{REMOTE_ADDR}=$options{ip}=$ip="76.16.109.166"; }
      $options{proxy}.="-cgi";
   }
	my $content_len=$request->header("Content-Length");
   my $request_body=read_post($r,$content_len);
	if(defined($request_body) && length($request_body)) {
	   $request->content($request_body);
	}
	if(defined($content_len) && !defined($request_body)) { $request->remove_header("Content-Length"); }

# user authorization check
   my $sth=$dbh->prepare_cached("SELECT `reason` FROM `ipban` WHERE `ip` = ?");
   my $res=$dbh->selectall_arrayref($sth, {}, $ip);
   if($res) {
      foreach(@$res) {
         $r->status(401);
         my $reason=$_->[0];
         $r->print("sorry: your IP $ip is banned in AWTools by AW's ForumAdmin. Reason given by him is: $reason\n");
         return;
      }
   }
   
 
# setup for pre-processing mangling and feeding
   $options{url}=$uri;
   $options{ip}=$ip;
   $options{post}=$request_body;
   $options{headers}=$headers_in;
   $options{req}=$r;
   $options{ua}=$UA;
   $options{request}=$request;
   $ENV{REMOTE_USER}="";
# setup $options{name} and $ENV{REMOTE_USER} from session cache
   my $tauth=[gettimeofday];
   my $cookie=$request->header("Cookie");
   my $user="";
   if($cookie && $cookie=~m/PHPSESSID=([0-9a-f]+)/) {
      my $s=$options{session}=$1;
      my $sth=$dbh->prepare_cached("
            SELECT `name` , m.`pid` , `tz`, `nclick`
            FROM `usersession` m
            LEFT JOIN playerprefs ON ( m.pid = playerprefs.pid )
            WHERE `sessionid` = ?
            AND `auth` =1
            LIMIT 1
         ");
      my $aref=$dbh->selectall_arrayref($sth, {}, $s);
      if($aref && $$aref[0]) {
         $user=$$aref[0][0];
         my $pid=$options{pid}=$$aref[0][1];
         $awstandard::timezone=$options{tz}=$$aref[0][2];
         $options{nclick}=$$aref[0][3];
#         my $sth=$dbh->prepare_cached("SELECT `tz` FROM `playerprefs` WHERE `pid` = ?");
#         my $aref=$dbh->selectall_arrayref($sth, {}, $pid);
#         if($aref && $$aref[0]) { $awstandard::timezone=$options{tz}=$$aref[0][0] }
      }
   }
	my $usercookie="";
   if($cookie && $cookie=~m/c_user=([^;,]*)/) { # caused security hole lwp-request "http://www1.astrowars.com/0/Player/Profile.php/?id=16201" -H "Cookie: PHPSESSID=946e8273629aa0b73079df9xxxxxxx;c_user=Jimmy" -p "http://awproxy.zq1.de:81"
      $usercookie=awstandard::urldecode($1);
		$ENV{HTTP_COOKIE}=$cookie;
#      $content.="<br>Cookie: $cookie";
#     $r->print($content);
#      return;
   }
   $options{name}=$user;
   $options{alli}=$ENV{REMOTE_USER}=awinput::playerid2alli($options{pid});
   if($usercookie && $options{pid} && $usercookie ne $user) {$options{alli}=$ENV{REMOTE_USER}=""} # map disagreeing users to guest
   $options{authelapsed} = tv_interval ( $tauth );

   { # do logging # but might impair performance
      # strip password for security reasons
      my $u=$uri;
      $u=~s%(http://www1\.astrowars\.com/register/login\.php).+%$1%;
      $u=~s%(http://www1\.astrowars\.com/register/customize_race\.php).+%$1%;
      my $uextra=($usercookie && $usercookie ne $user)?"/$usercookie":"";
      my $log=localtime()." IP:$ip u:$user$uextra a:$ENV{REMOTE_USER} $u\n";
      open(LOG, ">>", "/home/aw/inc/log/brownie.log");
      print LOG $log;
      close(LOG);
   }

# do pre-processing (e.g. do caching, adjust URLs or insert extra pages into AW namespace)
   our $browniedone=0;
   if(1 || $user eq "greenbird") {
      require "preproc/dispatch.pm";
      preproc::dispatch::preproc_dispatch(\%options);
   }
   if($browniedone) {
#      $r->status(200);
#      $r->print("preproc done $browniedone");
      return;
   }
   
# send request, fetch response
   my $t1 = [gettimeofday];
   my $response = $options{response} = $::options{response};   # might already be there from caching
   if(!$response) {
      $response = $options{response} = $UA->request($request);
   }
   my $t2 = [gettimeofday];
   $options{awelapsed} = tv_interval ( $t1, $t2 );
   $options{prerequestelapsed} = tv_interval( $t0, $t1);
   if(!$response) {# || !$response->header('Content-type')) {
      $r->status(500);
      $r->print("sorry: something went wrong on the AW-side of brownie\n");
      return;
   }

   my $content = $response->content;

   if($content =~m/500 Server closed connection without sending any data back/) {
      sleep 1;
      $response = $UA->request($request);
      $content = $response->content;#." (brownie retried after 'Server closed connection without sending any data back')";
   }
   if($content =~m/500 Can't connect to www1\.astrowars\.com:80 \(connect: timeout\)/) {
#      $response = $UA->request($request);
#      $content = $response->content." (brownie retried)";
      $content.=" please re-try";
      return;
   }
   if($response->code == 500) {
      $r->content_type("text/html");
      my $host="";
      if($uri=~m!^http://([^/]+)!) {$host=$1}
      $r->print("<pre>".gmtime().": The brownie proxy got no response from $host server. It might be down. <a href=\"http://www.astrowars.com/forums/viewtopic.php?t=30375\">Or slow</a></pre>");
      if($host eq "www.astrowars.com") {
         $r->print(qq'<a href="http://$awstandard::bmwproxyaddr/">game is still working - click here</a> ');
      }
		my $url="http://www.astrowars.com/forums/viewtopic.php?t=28261";
      #$r->print("see <a href=\"$url\">$url</a> </pre>");
      $r->print("\n<br/>error message: ".$content);
      return;
   }

# work around Alliance Details bug (only working after opening alliance page once)
   if(!$interbeta && $options{url}=~m!^(http://www1.astrowars.com/0/Alliance/)Detail! && !$content) {
      my $tmpr=HTTP::Request->new("GET", $1, $request);
      $UA->request($tmpr);
      $response = $UA->request($request);
      $content = $response->content."work around AW bug OK";
   }

# feed reponse back into our request_rec*
   $r->status($response->code);
   $r->status_line(join " ", $response->code, $response->message||"");
   
   my $ctype=$response->header('Content-type');
   if($ctype) {
      $ctype=~s%text/html, %%;
#   $r->print("debugging: ".$ctype); return;
      $r->content_type($ctype);
   }

   my $headers_out=[];
   $options{headers_out}=$headers_out;
   $response->scan(sub {
         if(lc $_[0] ne "connection") {
            $r->headers_out->add(@_);
            push(@$headers_out, \@_);
         }
   });
   $r->set_keepalive();
   $_=$content;
   if($uri=~m!^http://www\.astrowars\.com/forums/! && m!border="0" alt="Log out \[ (.{1,25}) \]" hspace="3" />Log out \[ \1 \]</a>&nbsp;</span>! && (my $pid=playername2idm($1))) {
      $options{name}=$user=$1;
      $options{pid}=$pid;
      $ENV{REMOTE_USER}=awinput::playername2alli($user)||"";
#      $_.=" $user $ENV{REMOTE_USER}\n";
   }
   if($options{pid}) {
      $ENV{HTTP_AWUSER}=$options{name};
      $ENV{HTTP_AWPID}=$options{pid};
   }

   if(!$ctype || ($response->code != 200 && $response->code != 302)) {
      return \$_;
   }
   my $awuri=$uri=~/^http:\/\/www1?\.astrowars\.com/;
   my $htmlcontent=$ctype=~m%text/html%;
   if($uri=~m{3/secure.php$}) {$htmlcontent=1}; #exception
# mangle HTML pages:
   if($htmlcontent && ($awuri || $uri=~/^http:\/\/forum\.rebelstudentalliance/ || $uri=~m/http:\/\/de.wikipedia/)) {
      awinput_init(1);
      $awstandard::timezone=$options{tz}; # was overwritten by init
      my $ret=require "mangle/dispatch.pm";
      if($ret && !$@ ) {
         mangle::dispatch::mangle_dispatch(\%options);
      } else {
         $_.="<br>greenbird probably coded an error in mangling: $@\n<br>";
      }
#      $_.="user:$user  alli:$ENV{REMOTE_USER}";# cookie: $cookie";
      awinput::awinput_finish();
   }
   
# debugging
   if(0 && $user eq "Banana9977") {
#      $_.="Cookie: $headers_in{Cookie}";
      $_.=$debuglog;
   }
   
   # special permissions for some players
   if($user eq "") {
#      $ENV{REMOTE_USER}="af";
   }
   
# feed into tools:
#   if($ENV{REMOTE_USER} && $awuri) {
   if($awuri) {
      my $t3 = [gettimeofday];
      if(!$debug) {
         open(STDOUT, ">", "/dev/null");
      }
      awinput_init();
      feed::dispatch::feed_dispatch($content, \%options);
      awinput::awinput_finish();
      $options{feedelapsed} = tv_interval ( $t3 );
   }
# print benchmarks
   if($htmlcontent && is_admin() && $r->content_type() eq "text/html") {
      my $totalt=tv_interval( $t0 );
      my $missingt=$totalt-$options{feedelapsed}-$options{mangleelapsed}-$options{prerequestelapsed}-$options{awelapsed};
      $_.= sprintf("feed:%ius missing:%ius total:%ius ", $options{feedelapsed}*1e6, $missingt*1e6, $totalt*1e6);
   }
   return \$_;
}

1;
