BEGIN {alarm 20;}
use awinput;

my $debug=1;

sub feed_dispatch($) { local $_=$_[0];
   awinput_init();
	if(! m!<title>([^<>]*)</title>!) { 
		my @race;
		if($::options{name}) { require './feed/plain_race.pm' }
		print "no title found\n"; return -1;
	}
	my $title=$1;
	my $aw="Astro Wars";
   if($title=~/- profile - $aw/) { require './feed/profile.pm'; return 0}
	return unless our @time=($title=~/(.*) - (\d+):(\d+):(\d+)/);
	$title=shift(@time);
   $module=title2pm($title);
	our $deliverytime;
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)=gmtime();
		$hour+=$::options{tz};
		my $servertime=$hour*3600+$min*60+$sec;
		my $localtime=$::time[0]*3600+$::time[1]*60+$::time[2];
		$deliverytime=($servertime-$localtime);
		if($deliverytime<(-24*60+50)*60) {$deliverytime+=24*60*60}
		if($deliverytime>(24*60-50)*60) {$deliverytime-=24*60*60}
      if(abs(bmwmod($deliverytime,3600))<30) {
         my $adjust=bmwround($deliverytime/3600);
         $::options{tz}-=$adjust;
         $deliverytime-=$adjust*3600;
         print "timezone adjusted to $::options{tz}, delivery $deliverytime s\n".br;
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
      require $include;
   } else {
		print "this input (title=$title) is not supported (yet) or not recognized\n";
   }
   awinput::awinput_finish();
	return 0;
}

1;
