use strict;
# link Bio25 systems
s%(<tr[^>]*><td>(?:<a href=Launch.php/\?nr=[^>]*><b>Launch</b></a>)?[^<]*</td><td><small>)\((\d+)\)(\s+\d+</small></td>)%$1$::bmwlink/system-info?id=$2">($2)</a>$3%g;

if($::options{name} eq "greenbird") {
#   eval q§use strict;
#      $_.="test2 OK";
#   § or $_.= $@;
}

1;
