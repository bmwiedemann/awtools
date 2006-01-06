package feed::dispatch;
# package assumes awinput_init has already run
use awstandard;
use awinput;
use CGI ":standard";

my $debug=0;

sub feed_dispatch($%) { (local $_, my $options)=@_;
   %::options=%$options;
	if(! m!<title>([^<>]*)</title>!) { 
		my @race;
		if($::options{name}) { require './feed/plain_race.pm'; feed_plain_race(); }
		print "no title found\n"; return -1;
	}
	my $title=$1;
	my $aw="Astro Wars";
   if($title=~/- profile - $aw/) { require './feed/profile.pm'; feed_profile(); return 0}
   my @time;
	return unless @time=($title=~/(.*) - (\d+):(\d+):(\d+)/);
	$title=shift(@time);
   $module=title2pm($title);
#our $deliverytime;
	{
      my $gtz=awstandard::guesstimezone(join(":",@time));
      print "guessed timezone: UTC+$gtz s".br;
		$::deliverytime=$::options{tz}*3600 - $gtz;
		if($::deliverytime<(-24*60+50)*60) {$::deliverytime+=24*60*60}
		if($::deliverytime>(24*60-50)*60) {$::deliverytime-=24*60*60}
      if(abs(bmwmod($::deliverytime,3600))<50) {
         my $adjust=bmwround($::deliverytime/3600);
         $::options{tz}-=$adjust;
         $::deliverytime-=$adjust*3600;
         print "timezone adjusted to $::options{tz}, delivery $::deliverytime s\n".br;
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
         print DEBUG localtime()." name=$::options{name} tz=$::options{tz} $include\n";
         close(DEBUG);
      }
      do $include;
   } else {
		print "this input (title=$title) is not supported (yet) or not recognized\n";
   }
	return 0;
}

1;
