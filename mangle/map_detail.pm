if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
   my $link=qq($::bmwlink/system-info?id=$id">);
   s%(Planets at)%$1 ${link}id=$id</a>%;
   if(s%<TABLE.*\z%Map / Detail</b></td>%) {
      my $l=$link;
      $l=~s/.*(http:)/$1/;
      $_.=qq'<iframe width="95%" height="700" src="$l</iframe></body></html>';
   }
   s%Map / Detail</b></td>%$&<td>${link}AWtools($id)</a></td><td>|</td>%;
}

1;
