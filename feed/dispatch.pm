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
   if($gameuri && (my $session=awstandard::cookie2session(${$$options{headers}}{Cookie}))) {
      if($$options{url}=~m%^http://www1\.astrowars\.com/register/login\.php%) {
         # reset click counter now
         $dbh->do("UPDATE `usersession` SET `nclick` = '0' WHERE `sessionid` = ".$dbh->quote($session));
      }
      my $time=time();
      if($$options{url}=~m%^http://www1\.astrowars\.com/0/%) {
         my $sth=$dbh->prepare_cached("UPDATE `usersession` SET `nclick` = `nclick` + 1 , `lastclick` = ? WHERE `sessionid` = ? LIMIT 1;");
         my $result=$sth->execute($time, $session);
         if($result==0) {
            # insert new entry with 1 click
            my $sth=$dbh->prepare_cached("INSERT INTO `usersession` VALUES ( ?, ?, 1, ?, ?);");
            $sth->execute($session, $$options{name}, $time, $time);
         }
      }
   }
   if(! m!<title>([^<>]*)</title>!) { 
		my @race;
		if($$options{name}) { require './feed/plain_race.pm'; feed_plain_race(); }
		print "no title found\n"; return -1;
	}
	my $title=$1;
	my $aw="Astro Wars";
   if($title=~/- profile - $aw/) { require './feed/profile.pm'; feed_profile(); return 0}
   my @time;
	return unless @time=($title=~/(.*) - (\d+):(\d+):(\d+)/);
	$title=shift(@time);
   my $module=title2pm($title);
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

   my $include="feed/$module.pm";
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
