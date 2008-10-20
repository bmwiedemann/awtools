use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});

my @entries=();
foreach my $line (m{<tr bgcolor="#303030".(.+?)</td></tr>}gs) {
	if($line=~m{^<td>}) {
		my @a=split("</td><td>",$');
		next unless ($a[0]);
		my @label=qw(name avg max);
		my %a=();
		for my $n(0..$#label) {$a{$label[$n]}=$a[$n]}
		if(!defined($a{max})) {delete($a{max})}
		else {$a{max}+=0;}
		$a{avg}+=0;
		$a{name}=~s{<a [^>]+>([^<>]+)</a>}{$1};
		push(@entries, \%a);
	} else {
		$d->{debug}=$line;
	}
}
$d->{entry}=\@entries;

parselastupdate(\$_);

2;
