package feed::dispatch;
# package assumes awinput_init has already run
use strict;
use CGI ":standard";
use awstandard;
use awinput;
use DBAccess;

my $debug=0;

sub feed_dispatch($%) { (local $_, my $options)=@_;
   my $gameuri=defined($$options{url}) && $$options{url}=~m%^http://www1\.astrowars\.com/%;
   my($title)=m!\A.{0,200}<title>([^<>]*)</title>!s;
	my $aw="Astro Wars";
   if($$options{name} && $gameuri && (my $session=awstandard::cookie2session(${$$options{headers}}{Cookie}))) {
#      if($$options{url}=~m%^http://www1\.astrowars\.com/register/login\.php%) {
         # reset click counter now
#         $dbh->do("UPDATE `usersession` SET `nclick` = '0' WHERE `sessionid` = ".$dbh->quote($session));
#      }
      my $time=time();
      if($$options{url}=~m%^http://www1\.astrowars\.com/(?:\w+/)?0/%) {
         my $sth=$dbh->prepare_cached("UPDATE `usersession` SET `nclick` = `nclick` + 1 , `lastclick` = ? WHERE `sessionid` = ? LIMIT 1;");
         my $result=$sth->execute($time, $session);
         
         my $sth2=$dbh->prepare_cached("
               INSERT INTO `brownieplayer` VALUES ( ?, ?, ?, 0, 0)
               ON DUPLICATE KEY UPDATE `lastclick_at` = ?
               ;");
         $sth2->execute($$options{pid}, $time,$time,$time);
         if($title && ($title ne $aw)) {
            my $sth3=$dbh->prepare_cached("UPDATE `brownieplayer` SET `lastupdate_at` = ? WHERE `pid` = ? AND `lastupdate_at` < ?");
            $sth3->execute($time, $$options{pid}, $time-$awstandard::updatetime15);
         }

#         if($result eq "0E0") {
            # insert new entry with 1 click
#            my $sth=$dbh->prepare_cached("
#               INSERT INTO `usersession` VALUES ( ?, ?, ?, 1, ?, ?, ?, 0)
#               ON DUPLICATE KEY UPDATE `nclick` = `nclick` + 1 , `lastclick` = ?
#               ;");
#            $$options{ip}||="";
#            $sth->execute($session, $$options{pid}, $$options{name}, $time, $time, $$options{ip}, $time);
#         }
      }
   }
   if(! defined($title)) { 
		my @race;
      %::options=%$options;
		if(1||$$options{name}) { require feed::plain_race; feed::feed_plain_race(); }
		print "no title found\n";
      return -1;
	}
   print "title $title\n";
   if($title=~/- profile - $aw/o) { require feed::profile; feed_profile(); return 0}
   my @time;
   my $url=$$options{url};
	return unless @time=($title=~/(.*) - (\d+):(\d+):(\d+)/) or $url=~m{/rankings/};
	$title=shift(@time);
   my @module=();
   my $module=title2pm($title);
   push(@module, url2pm($url), (1 ? $module :()));
   my $include;
   foreach my $m (@module) {
      $include="$awstandard::codedir/feed/$m.pm";
      next if(!-e $include);
      $module=$m;
      last;
   }
#   awdiag("$module: $module $url");
#our $deliverytime;
	{
      my $gtz=awstandard::guesstimezone(join(":",@time));
      print "guessed timezone: UTC+$gtz s".br;
		$::deliverytime=$$options{tz}*3600 - $gtz;
		if($::deliverytime<(-24*60+50)*60) {$::deliverytime+=24*60*60}
		if($::deliverytime>(24*60-50)*60) {$::deliverytime-=24*60*60}
      if(abs(bmwmod($::deliverytime,3600))<50) {
         my $adjust=bmwround($::deliverytime/3600);
         $$options{tz}-=$adjust;
         $::deliverytime-=$adjust*3600;
         print "timezone adjusted to $$options{tz}, delivery $::deliverytime s\n".br;
      }
      if($::deliverytime<-60 || $::deliverytime>50*60) {
         print "data is outdated or wrong timezone? (delivery took $::deliverytime seconds)";
         return -2;
      }
	}

   print "$module feed".br;
   if(-e $include) {
      if($debug) {
         open(DEBUG, ">>", "/tmp/awfeeddebug") or die $!;
         print DEBUG localtime()." name=$$options{name} tz=$$options{tz} $include\n";
         close(DEBUG);
      }
      %::options=%$options;
      do $include;
   } else {
		print "this input (title=$title) is not supported (yet) or not recognized\n";
   }
	return 0;
}

1;
