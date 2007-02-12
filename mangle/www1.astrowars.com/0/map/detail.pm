if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
   my $link=$::bmwlink.awstandard::awsyslink($id);
   my $frame=$link;
   $frame=~s/.*(http:)/$1/;
   $link=~s/(simple=)\d/$1/; # enable full view for links
   s%(Planets at)%$1 ${link}id=$id</a>%;
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
