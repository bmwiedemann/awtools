use strict;
use awinput;

# add system ID tool links
s%(<tr align=center bgcolor=#\d+><td[^>]*>)(\d+)(</td><td)%$1$::bmwlink/system-info?id=$2">$2</a>$3%g;

# add next and prev buttons
if($::options{url}=~/id=(\d+)/) {
   my $id=$1;
   my $url=$::options{url};
   $url=~s/(id=)\d+/$1/;
   my $previd=$id-1;
   my $nextid=$id+1;
   my $prevstring="";

   s%([^<>]*)(<br><table border=0)%
      my $id=playername2id($1);
      my $x=$1;
      if($id) { $x="<a class=\"awtools\" href=\"/0/Player/Profile.php/?id=$id\">$1</a>"; }
      $x.$2%e;
   if($previd>=0) { $prevstring=qq'<a class="awtools" href="$url$previd">prev</a>'; }
   s%<br><table border=0%<br>$prevstring <a class="awtools" href="$url$nextid">next</a>$&%;
   do "mangle/www1.astrowars.com/0/alliance.pm";
}

require "mangle/special_color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();

1;
