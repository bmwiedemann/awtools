use strict;
use awinput;

# link Bio25 systems
s%(<tr[^>]*><td>(?:<b>pending</b>)?(?:<a href=Launch.php/\?nr=[^>]*><b>Launch</b></a>)?[^<]*</td><td><small>)\((\d+)\)(\s+\d+</small></td>)%$1$::bmwlink/system-info?id=$2">($2)</a>$3%g;




sub gettt($)
{my($awtstr)=@_;
   my $time=parseawdate($awtstr);
   return sprintf("%.2fh&nbsp;", ($time-time())/3600-$::options{tz});
}

s%<td width="135"><small>Estimated Arrival</small></td>%<td width="185"><small>Estimated Arrival</small></td>%;
s%(<tr bgcolor="?#?404040"? align="?center"?><td>)([^<]+)</td>%$1.gettt($2).$2.$3%ge;

1;
