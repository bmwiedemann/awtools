use strict;
use awparser;

my @planets=();
foreach my $line (m{<tr.(.+?)</td></tr>}g) {
	if($line=~m{^bgcolor="#303030" align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n sid pid pop cv);
		my %a=();
		for my $n(0..4) {$a{$label[$n]}=$a[$n]}
		push(@planets, \%a);
	} elsif($line=~m{^<td bgcolor="#202020">}) {
		my @a=split("</td><td>",$');
		my $k=lc(shift(@a));
		$k=~s/[^a-z]//g;
		$d->{$k}=shift(@a);
	} elsif($line=~m{^bgcolor=#404040 align=center><td colspan=3>Points: }) {
		my @a=split("</td><td>",$');
		$d->{points}={total=>shift(@a), "pop"=>shift(@a), "cv"=>shift(@a)};
	} else {
		# TODO a lot
		$d->{debug}=$line;
	}
}
$d->{planet}=\@planets;

2;
