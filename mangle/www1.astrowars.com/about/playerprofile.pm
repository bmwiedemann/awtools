use awsql;
use parse::dispatch;
my $data=parse::dispatch::dispatch(\%::options);

if($::options{url}=~m%^http://www1\.astrowars\.com/about/playerprofile.php\?((?:id)|(?:name))=(.+)%) { 
   my $id=$2;
   my $arg=$1;
   s%^</td></tr></table>%$& $::bmwlink/relations?$arg=$id">AWtools($id)</a><br>%m;
   my $prem=m!<small>Premium Member</small>! || 0;
   my $pid=$id;
   if($arg eq "name") {$pid=playername2idm($id);}
   update_premium($pid, $prem);
}

my $totalpop10=0;
foreach my $planet (@{$data->{planet}}) {
	my $pop10=$planet->{"pop"}-10;
	next if $pop10<=0;
	$totalpop10+=$pop10;
}
my $plpoints=$data->{playerlevel};
my $scipoints=$data->{points}->{total} - $data->{points}->{"pop"} - $plpoints*2;
my $totalpoints=$totalpop10+$plpoints+$scipoints;
s{colspan=3>Points: \d+</td><td>\d+</td><td>\d+</td></tr>}{$&<tr bgcolor="#306030"><td colspan="3" align="center">points = $totalpop10+$plpoints+$scipoints</td><td>$totalpoints</td></tr>};

1;
