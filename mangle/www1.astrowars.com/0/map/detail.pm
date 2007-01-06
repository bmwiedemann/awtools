if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
   my $link=$::bmwlink.awstandard::awsyslink($id);
   my $l=$link;
   $l=~s/.*(http:)/$1/;
   s%(Planets at)%$1 ${link}id=$id</a>%;
   if(s%<TABLE.*\z%Map / Detail</b></td>%) {
      $_.=qq'<iframe width="95%" height="700" src="$l</iframe></body></html>';
   }
   s%Map / Detail</b></td>%$&<td>${link}AWtools($id)</a></td><td>|</td>%;
#   if($ENV{REMOTE_USER}) {
      s%Coordinates</a></td>\n</tr>\n</table>%$& <br><iframe width="95\%" height="900" src="$l</iframe>%;
#   }
   $::extralink="${link}AWtools($id)</a>";
}

1;
