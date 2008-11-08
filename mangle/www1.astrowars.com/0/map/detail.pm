if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
	my($pid)=($::options{url}=~/&highlight=(\d+)/);
   my $link=$::bmwlink.awstandard::awsyslink($id,1,$pid);
   my $frame=$link;
   $frame=~s/.*(http:)/$1/;
   $link=~s/(simple=)\d/$1/; # enable full view for links
   s%(Planets at)%$1 ${link}id=$id</a>%;
	# highlight planet
	s{(<tr bgcolor="#\d+" align=center)(><td>$pid</td><td>)}{$1 style="font-weight: bold; font-size: 1.3em;"$2};

   if(s%<TABLE.*\z%Map / Detail</b></td>%) {
      $_.=qq'<iframe width="95%" height="700" src="$frame</iframe></body></html>';
   }
   s%Map / Detail</b></td>%$&<td>${link}AWtools($id)</a></td><td>|</td>%;
#   if($ENV{REMOTE_USER}) {
      s%Coordinates</a></td>\n</tr>\n</table>%$& <br><iframe width="95\%" height="900" src="$frame</iframe>%;
#   }
   $::extralink="${link}AWtools($id)</a>";
}

1;
