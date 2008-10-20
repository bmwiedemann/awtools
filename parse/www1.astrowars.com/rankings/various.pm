use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});
($d->{totalplayers})=(m{Players By Country. (\d+) joined this round.});

my @entries=();
foreach my $line (m{ width="22" height="13" border="0" alt="(\w+"></a></td><td>[0-9.]+)%</td>}g) {
	if($line=~m{^(\w+)"></a></td><td>([0-9.]+)$}) {
		push(@entries, {country=>$1, percent=>$2});
	} else {
		$d->{debug}=$line;
	}
}
$d->{entry}=\@entries;

parselastupdate(\$_);

2;
