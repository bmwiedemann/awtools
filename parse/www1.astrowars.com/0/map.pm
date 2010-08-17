use strict;
use awparser;

m{<table cellpadding="0" cellspacing="0" border="0" background="/images/startile.gif" width="600" align="center" valign="center" height="400">(.*?)</table>}s;
my $map=$1;

my @system=();
foreach my $line ($map=~m{<td><a href="Detail.php/\?nr=(.+?)</td>}gs) {
	if($line=~m{^(\d+)"><img src="/images/star(\d+).gif" alt="([^"]+)" title=".*\((-?\d+)/(-?\d+)\)\nID:\d+\nLevel: (\d+)}) {
		push(@system, {id=>int($1), levelimg=>int($2), name=>$3, x=>int($4), y=>int($5), level=>int($6)});
	}
}

my @a=($map=~m{<tr align=center>}g);
$d->{mapsize}=scalar @a;

$d->{system}=\@system;

2;
