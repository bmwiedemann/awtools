use strict;
use awparser;

my($title)=m!\A.{0,200}<title>([^<>]*)</title>!s;
$d->{"title"}=$title;
my $ret=2;
if($title eq "Astro Wars Login") {
	if(m{<legend>Security Measure</legend>}) {
		$d->{security}=1;
		$ret=1;
	} elsif(m{<legend>Please login again</legend>}) {
		$d->{relogin}=1;
		$ret=1;
	}
} else {
   ($title,my @time)=($title=~/(.*) - (\d+):(\d+):(\d+)/);
   $title=~s/^\s+//;
   $d->{"title"}=$title;
   $d->{"time"}=join(":",@time);
   $d->{"timesec"}=$time[0]*3600+$time[1]*60+$time[2];

   $d->{"trade"}=tobool(m{<li><a href="/\d+/Trade/" accesskey=".">Trade</a></li>});
   $d->{"alliance"}=tobool(m{<li><a href="/\d+/Alliance/" accesskey=".">Alliance</a></li>});
# add timezone detector
	$d->{"timezone"}=awstandard::guesstimezone($d->{"time"});

}

$ret;
