# add system ID tool links
s%(<tr align=center bgcolor=#\d+><td>)(\d+)(</td><td)%$1<a href="http://$::bmwserver/cgi-bin/system-info?id=$2">$2</a>$3%g;

# add next and prev buttons
if($::options{url}=~/id=(\d+)/) {
   my $id=$1;
   my $url=$::options{url};
   $url=~s/(id=)\d+/$1/;
   my $previd=$id-1;
   my $nextid=$id+1;
   s%<br><table border=0%<br><a href="$url$previd">prev</a> <a href="$url$nextid">next</a>$&%;
}

1;
