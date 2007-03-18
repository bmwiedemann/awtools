use strict;
# link Bio25 systems
s%(<tr[^>]*><td>(?:<b>pending</b>)?(?:<a href=Launch.php/\?nr=[^>]*><b>Launch</b></a>)?[^<]*</td><td><small>)\((\d+)\)(\s+\d+</small></td>)%$1$::bmwlink/system-info?id=$2">($2)</a>$3%g;

1;
