if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
	my($pid)=($::options{url}=~/&highlight=(\d+)/);
   my $link=$::bmwlink.awstandard::awsyslink($id,1,$pid);
   my $frame=$link;
   $frame=~s/^[^\/]*(\/)/$1/;
   $link=~s/(simple=)\d/$1/; # enable full view for links
   s%(Planets at )(ID \d+)%$1 ${link}$2</a>%;
	# highlight planet
	s{(<tr)(?: class="(\w+)")?(>\s*<td>$pid</td>\s*<td>)}{$1 class="highlighted $2"$3};

	$frame.="[Your user agent does not support frames or is currently configured not to display frames.]";
   s{This system is out of your biology range.*updated once a day\)\.}
	{$&<br/>or greenbird's version updated whenever someone in range views the system: <iframe width="95%" height="700" src="$frame</iframe></body></html>}s;
   s%Map / Detail</b></td>%$&<td>${link}AWtools($id)</a></td><td>|</td>%;
#   if($ENV{REMOTE_USER}) {
      s%\n</table>%$& <br><iframe width="95\%" height="900" src="$frame</iframe>%;
#   }
   $::extralink="${link}AWtools($id)</a>";
}

1;
