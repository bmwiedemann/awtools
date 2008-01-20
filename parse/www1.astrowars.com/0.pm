use strict;
use awparser;

my($title)=m!\A.{0,200}<title>([^<>]*)</title>!s;
$d->{"title"}=$title;
my $ret=2;
if(m{^<html><head><title>Astro Wars</title>} && m{<font color="#FF0000" size="5"><b>Please Login Again.</b></font><form action="/register/login.php" method="post" name=login>}) {
   $d->{relogin}=1;
   $ret=1;
} else {
   ($title,my @time)=($title=~/(.*) - (\d+):(\d+):(\d+)/);
   $title=~s/^\s+//;
   $d->{"title"}=$title;
   $d->{"time"}=join(":",@time);
   $d->{"timesec"}=$time[0]*3600+$time[1]*60+$time[2];

   $d->{"trade"}=tobool(m{^<td>|</td><td><a href="/0/Trade/" class="white">Trade</a></td>});
   $d->{"alliance"}=tobool(m{^<td>|</td><td><a href="/0/Alliance/" class="white">Alliance</a></td>});

# TODO add timezone detector

}

$ret;
