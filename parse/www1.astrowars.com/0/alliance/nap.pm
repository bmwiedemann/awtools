use strict;
use awparser;
use awstandard;

my @alliancenaps;
my @playernaps;
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}g) {
	if($line=~m{/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a></td><td>(\d+:\d+:\d+ - [A-Z][a-z][a-z] \d\d)</td>$}) {
		push(@playernaps, {pid=>int($1), name=>$2, established=>parseawdate($3)} );
	} elsif($line=~m{/rankings/alliances/(\w+).php>([^<]+)</a></td><td>(\d+:\d+:\d+ - [A-Z][a-z][a-z] \d\d)</td>$}) {
		push(@alliancenaps, {tag=>$1, name=>$2, established=>parseawdate($3)} );
	}
}
$d->{alliancenap}=\@alliancenaps;
$d->{playernap}=\@playernaps;

2;
