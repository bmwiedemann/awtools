use awstandard;
use awinput;
use awsql;

my $data=getparsed(\%::options);
if($::options{url}=~m%^http://www1\.astrowars\.com/about/playerprofile.php\?((?:id)|(?:name))=(.+)%) { 
   my $id=$2;
   my $arg=$1;
   s%^</td></tr></table>%$& $::bmwlink/relations?$arg=$id">AWtools($id)</a><br>%m;

#  update premium bit
   my $pid=$id;
   if($arg eq "name") {$pid=playername2idm($id);}
   update_premium($pid, $data->{premium});

#  link star systems in CD
	foreach my $p (@{$data->{planet}}) {
		s{(align=center><td>$p->{n}</td><td>)$p->{sid}}{$1$::bmwlink/system-info?id=$p->{sid}&target=$p->{pid}">$p->{sid}</a>};
	}

}

1;
