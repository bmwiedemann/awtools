use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});

my @planets=();
foreach my $line (m{<tr bgcolor="#262626".(.+?)</td></tr>}gs) {
	if($line=~m{^align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n ds cs bs owner);
		my %a=();
		if($a[4]=~m{^<a href=/about/playerprofile\.php\?id=(\d+)>([^<>]+)</a>$}) {$a[4]={id=>$1, name=>$2}}
		for my $n(0..$#label) {$a{$label[$n]}=$a[$n]}
		$a{cv}=$a[1]*3+$a[2]*24+$a[3]*60;
		push(@planets, \%a);
	} else {
		$d->{debug}=$line;
	}
}
$d->{planet}=\@planets;

parselastupdate(\$_);

2;
