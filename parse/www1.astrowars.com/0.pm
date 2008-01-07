use strict;
use awparser;
my($title)=m!\A.{0,200}<title>([^<>]*)</title>!s;
($title,my @time)=($title=~/(.*) - (\d+):(\d+):(\d+)/);
$title=~s/^\s+//;
$d->{"title"}=$title;
foreach my $t (@time) {$t+=0}
$d->{"time"}=\@time;
$d->{"timesec"}=$time[0]*3600+$time[1]*60+$time[2];

$d->{"trade"}=tobool(m{^<td>|</td><td><a href="/0/Trade/" class="white">Trade</a></td>});
$d->{"alliance"}=tobool(m{^<td>|</td><td><a href="/0/Alliance/" class="white">Alliance</a></td>});

2;
