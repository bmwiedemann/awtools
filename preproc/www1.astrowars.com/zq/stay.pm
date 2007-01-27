use strict;
BEGIN {$ENV{HTTP_COOKIE}=$::options{headers}->{Cookie};} # allow parsing cookies from CGI module
use warnings;
use CGI;

my $bg=1;
my $r=$::options{req};
$r->content_type("text/html");
my $request=$::options{request};

my $h=$::options{headers};
(my $urlparam)=($::options{url}=~/\?(.*)/);
my $param=$::options{post}||$urlparam;
my $q = new CGI($param);
my $m="";
my $sessionid=$q->cookie("PHPSESSID");
if($q->param("time") && $sessionid) {
   my $times=$q->param("time");
   $m="p=$param t=$times\n";
   my %newh;
   my $re=$::options{request};
   foreach my $k (qw(Via X-Forwarded-For Accept Accept-Language Accept-Encoding Accept-Charset Cookie User-Agent)) {
      $newh{$k}=$re->header($k);
   }
   my @headers=%newh;
#   my @newh=%newh; print "headers @newh ";
   my $pid;
   if($bg) {
      $pid=fork();
      $m.=" ".localtime()." forked as $pid\n";
   }
   if(defined($pid) && $pid==0) { # child process
      {
         require DBAccess;
         require Tie::DBI;
         my $dbh=$DBAccess::dbh;
         my %options=%::options;
         my %us; # usersession
         tie %us,'Tie::DBI',$dbh,'usersession','sessionid',{CLOBBER=>2};
         my @site=qw"Player/Profile.php/?id=152603 Player/Profile.php/?id=29732 Player/Profile.php/?id=79995 Player/Profile.php/?id=37940 Player/Profile.php/?id=79995 Player/Profile.php/?id=175316 Fleet/ News/";
         my $lasturi="http://www1.astrowars.com/0/News/";
         for my $n(1..$times) {
            if($bg) { sleep 60; }
            my $now=time();
            my %lus=%{$us{$sessionid}};
            if($lus{nclick}>300) {last};
            my $tdiff=$now-$lus{lastclick};
            if($tdiff>2*60+rand(6*60)) {
               my $page=$site[rand(@site)];
               my $uri="http://www1.astrowars.com/0/$page";
               my $request = HTTP::Request->new("GET", $uri, \@headers);
               if($lasturi) {
                  $request->header(Referer=>$lasturi);
               }
               my $response=$::options{ua}->request($request);
               my $content=$response->content();
               {
                  awinput_init();
                  feed::dispatch::feed_dispatch($content, \%options);
                  awinput::awinput_finish();
               }
#               $lasturi=$uri;
               $lus{nclick}++;
               $lus{lastclick}=$now;
               $us{$sessionid}=\%lus;
#            my @lus=%lus; print "@lus\n";
               
               open(F, ">>/tmp/awstay.log");
               print F "$n $$ $now $uri ",length($content),"\n";
               close F;
            }
         }
         untie %us;
      }
#      exit(0); # exit is overruled by ModPerl so we can not easily use it here. it causes some extra loop with another fork
      if($bg) {
         use POSIX;
         POSIX::_exit(0); # end the extra background thread
      }
   }
}

$r->print( $q->start_html(-title=>"AW stay"),$m,$q->br,$q->start_form(-name=>"form"),$q->textfield(-name=>'time', -class=>'text'),$q->br,
      $q->submit(-name=>"query", -class=>'smbutton'),$q->br);

1;
