sub feed_dispatch($) { local $_=$_[0];
	if(! m!>([^<>]*)</title>!) { 
		my @race;
		if($::options{name}) { require './feed/plain_race.pm' }
		print "no title found\n"; exit 0;
	}
	my $title=$1;
	my $aw="Astro Wars";
	our @time=($title=~/ - (\d+):(\d+):(\d+)/);
	our $deliverytime;
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)=gmtime();
		$hour+=$::options{tz};
		my $servertime=$hour*3600+$min*60+$sec;
		my $localtime=$::time[0]*3600+$::time[1]*60+$::time[2];
		$deliverytime=($servertime-$localtime);
		if($deliverytime<(-24*60+50)*60) {$deliverytime+=24*60*60}
	}
        if($::deliverytime<-60 || $::deliverytime>50*60) {
                print "data is outdated or wrong timezone? (delivery took $::deliverytime seconds)";
                exit(0);
        }

	if($title=~m!Alliance / Detail!) {
		require './feed/alliance_detail.pm';
	} elsif ($title=~m!Player / Profile!) {
		require './feed/player.pm';
	} elsif ($title=~m!Map / Detail!) {
		require './feed/map_detail.pm';
	} elsif ($title=~m!Fleet!) {
		require './feed/fleet.pm';
	} elsif ($title=~m!$aw Trade / Agreement!) {
		require './feed/trade_agreement.pm';
	} elsif ($title=~m!$aw Science!) {
		require './feed/science.pm';
	} elsif ($title=~m!$aw News!) {
		require './feed/news.pm';
	} else {
		print "this input (title=$title) is not supported (yet) or not recognized\n";
	}
}

1;
