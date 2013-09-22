use strict;
use awinput;

# link Bio25 systems
s%(<tr[^>]*>\s*<td>.*?</td>\s*<td>)(\d+)#(\d+)(</td>)%$1$::bmwlink/system-info?id=$2&target=$3">$2#$3</a>$4%g;



# add relative travel time
sub gettt($)
{my($awtstr)=@_;
   my $time=parseawdate($awtstr);
   return sprintf("%.2fh&nbsp;", ($time-time())/3600-$::options{tz});
}

#s%<td width="135"><small>Estimated Arrival</small></td>%<td width="185"><small>Estimated Arrival</small></td>%;
s%(<tr>\s*<td>)([^<]+)</td>%$1.gettt($2).$2%ge;

1;
