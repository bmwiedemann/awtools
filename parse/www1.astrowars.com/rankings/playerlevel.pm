use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});

my @entries=();
foreach my $line (m{<tr bgcolor="#262626".(.+?)</td></tr>}g) {
	if($line=~m{^align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n owner level percent);
		my %a=();
		if($a[1]=~m{^<a href=/about/playerprofile\.php\?id=(\d+)>([^<>]+)</a>$}) {$a[1]={id=>$1, name=>$2}}
		for my $n(0..$#label) {$a{$label[$n]}=$a[$n]}
		push(@entries, \%a);
	} else {
		$d->{debug}=$line;
	}
}
$d->{entry}=\@entries;

parselastupdate(\$_);

2;
