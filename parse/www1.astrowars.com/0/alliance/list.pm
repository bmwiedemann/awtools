use strict;
use awparser;

my @members=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if(my @a=($line=~m{^#303030[^>]+id=\d+'"><td><a href=/0/Alliance/Detail.php/\?id=(\d+)>([^<]+)</a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(.*)</td><td>(\d+)</td><td>(\d+)</td><td>(\w+ \d)</td><td>(\d+)([mhsd])</td>})) {
		my $sci=$a[5];
		my @sci=split("</td><td>",$sci);
		my $currentsci=-1;
		for (my $n=0; $n<=$#sci; $n++) {
			if($sci[$n]=~s{<font color=#80b0b0>(\d+)</font>}{$1}) {
				$currentsci=$n;
			}
		}
		for my $n(0,2..4,6,7,9) {$a[$n]+=0}
		push(@members, {id=>$a[0], name=>$a[1], rank=>$a[2], points=>$a[3], pl=>$a[4], cul=>$a[6], trade=>$a[7], artifact=>$a[8], idle=>$a[9], idleunit=>$a[10], sciences=>\@sci, currentresearch=>$currentsci});
	}
}
$d->{members}=\@members;

if(m{<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600"><tr><td><center>([^<]*)<br>}) {
	$d->{name}=$1;
}

foreach my $m ("next", "previous") {
	if(m{Alliance/List.php/\?start=(\d+)><b>$m</b></a>}) {
		$d->{$m}=int($1);
	}
}

2;
