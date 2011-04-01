use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});

my @planets=();
foreach my $line (m{<tr bgcolor="#262626".(.+?)</td></tr>}gs) {
	if($line=~m{^align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n location cv owner);
		my %a=();
		if($a[3]=~m{^<a href=/about/playerprofile\.php\?id=(\d+)>([^<>]+)</a>$}) {$a[3]={id=>int($1), name=>$2}}
		$a[0]+=0;
		$a[2]+=0;
		if($a[1]=~m{<a href="?/about/starmap\.php\?dx=(-?\d+)&dy=(-?\d+)"?>([^<>]+) (\d+)</a>$}) {$a[1]={x=>int($1), y=>int($2), name=>$3, pid=>int($4)}}
		for my $n(0..$#label) {$a{$label[$n]}=$a[$n]}
		push(@planets, \%a);
	} else {
		$d->{debug}=$line;
	}
}
$d->{planet}=\@planets;

parselastupdate(\$_);

2;
