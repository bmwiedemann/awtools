use strict;
use awparser;

my @planets=();
foreach my $line (m{<tr bgcolor=(.+?)</tr>}g) {
	if($line=~m{"#303030" align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n sid pid pop cv);
		my %a=();
		for my $n(0..4) {$a{$label[$n]}=$a[$n]}
		push(@planets, \%a);
	} else {
		# TODO a lot
		$d->{debug}=$line;
	}
}
$d->{planet}=\@planets;

2;
