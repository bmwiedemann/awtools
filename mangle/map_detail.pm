if($::options{url}=~/nr=(\d+)/) {
   my $id=$1;
   my $link=qq($::bmwlink/system-info?id=$id">);
   s%(Planets at)%$1 ${link}id=$id</a>%;
   s%Map / Detail</b></td>%$&<td>${link}AWtools($id)</td><td>|</td>%;
}

1;
