use strict;
use awparser;

my @members=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if(my($pid,$name,$rank,$points,$pl,$sl,$cl,$x,$y)=($line=~m{<td><a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(-?\d+)/(-?\d+)</td>})) {
		my $counting=tobool($line=~m/^#303030/);
		push(@members, {pid=>$pid, name=>$name, rank=>$rank, points=>$points,
			pl=>$pl, cl=>$cl, x=>$x, y=>$y, counting=>$counting});
	} elsif($line=~m{^#404040><td>#(\d+)\((\d+)\)</td><td>(\d+)</td><td><b>(\d+)</b></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>}) {
		$d->{summary}={livingmembers=>$1, members=>$2, rank=>$3, points=>$4, pl=>$5, sl=>$6, cl=>$7};
	} else {
#		$d->{debug}=$line;
	}
}
$d->{member}=\@members;

if(m!<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"><tr><td><center>([^<]{1,60}) - <small>(.*)!) {
	$d->{name}=$1;
	if($2=~m!(http://[^>]+)</a></small><br><table border=0!) {
		$d->{url}=$1;
	}
	
}

2;
