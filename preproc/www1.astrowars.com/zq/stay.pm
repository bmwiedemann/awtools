use strict;
use warnings;
use CGI;
use Tie::DBI;
use DBAccess2;

my $bg=1;
my $r=$::options{req};
$r->content_type("text/html");
my $request=$::options{request};

my $h=$::options{headers};
(my $urlparam)=($::options{url}=~/\?(.*)/);
my $param=$::options{post}||$urlparam;
$ENV{HTTP_COOKIE}=$::options{headers}->{Cookie}; # allow parsing cookies from CGI module
my $q = new CGI($param);
my $sessionid=$q->cookie("PHPSESSID");
my $times=$q->param("time");
my $m="sessionid=$sessionid p=$param time=$times";
if($times && $sessionid) {
   $m.=" t=$times\n";
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
         my $dbh=get_dbh;
         my %options=%::options;
         my %us; # usersession
         tie %us,'Tie::DBI',$dbh,'usersession','sessionid',{CLOBBER=>2};
         my @site=qw"Fleet/ News/";
         foreach my $n (qw(154597 153149)) {
            push(@site, "Player/Profile.php/?id=$n");
         }
         my $lasturi="http://www1.astrowars.com/0/News/";
         for my $n(1..$times) {
            if($bg) { sleep 60; }
            my $now=time();
            my %lus=%{$us{$sessionid}};
            if($lus{nclick}>300) {last};
            my $tdiff=$now-$lus{lastclick};
            if($tdiff>5*60+rand(6*60)) {
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

$r->print( $q->start_html(-title=>"AW stay"),$m,$q->br,$q->start_form(-name=>"form", -method=>"get", -enctype=>"multipart/form-data"),$q->textfield(-name=>'time', -class=>'text')," minutes",$q->br,
      $q->submit(-name=>"query", -class=>'smbutton'),$q->end_form,$q->br);

1;
