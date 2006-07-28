#s%^<b>Alliance</b></td>%$& <td>$::bmwlink/alliance?alliance=$ENV{REMOTE_USER}">AWtools</a></td><td>|</td>%m;
my $alli=$ENV{REMOTE_USER};
s%<td><a href=/0/Alliance/>Overview</a></td>%<td>$::bmwlink/alliance?alliance=$alli">AWtools($alli)</a></td><td>|</td> $&%;


# add direct links for details pages
if($::options{url}=~m%/0/Alliance/$%) {
   my $n=0;
   s%(<td>)(\d+)(</td><td><a href=http://www.astrowars.com/forums/privmsg.php)%$1.'<a href="Detail.php/?id='.$n++.'">'.$2."</a>".$3%ge;
#   s%</body>%<span class="bmwnotice">note: new direct links behind points of players.</span><br>$&%;
}

1;
