use awstandard;
use DBAccess2;

my $data=getparsed(\%::options);
my $allicd=selectall_arrayref("SELECT *
FROM `alliances`
WHERE daysleft >=0
ORDER BY `alliances`.`daysleft`, `alliances`.`points` DESC");

if($allicd && $allicd->[0]) {
	my $nalli=0;
#	$_.=@$allicd;

	foreach my $e (@{$data->{entry}}) {
		my $dl=$e->{daysleft};
		if($dl==-1){$dl=1000}
		while((my $alli=$allicd->[$nalli]) && $allicd->[$nalli]->[3] < $dl) {
			++$nalli;
			# insert $alli above $e
#			my @e=%$e; $_.="@$alli -- @e";
			s{<tr bgcolor="#\d+" align=center><td>$e->{n}</td>}{<tr bgcolor="#402525" align="center"><td>A$nalli</td><td>$alli->[1]</td><td><a href="alliances/$alli->[1].php">$alli->[7]</a><small> ($alli->[3] days)</td><td>$alli->[5]</td><td></td></tr>$&};
			
		}
		last if $dl>=1000;
	} 
}

2;
