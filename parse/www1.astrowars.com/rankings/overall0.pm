use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]*)</title>});

my @entries=();
foreach my $line (m{<tr bgcolor="#(?:262626|402525)".(.+?)</td></tr>}gs) {
	$line=~s/ bgcolor="#\d+"//g;
	if($line=~m{^align=center><td>}) {
		my @a=split(qr"</td><td>",$');
		my $daysleft=-1;
# set countdown/daysleft
		$daysleft=$1 if($a[2]=~s/<small>(\d+) day.*<\/small>//);
		my @label=qw(n ndiff name points pointsdiff);
		my %a=();
		if($a[2]=~m{^<a href=/about/playerprofile\.php\?id=(\d+)>([^<>]+)</a>\s*$}) {$a[2]={id=>$1, name=>$2}}
		for my $n(0..$#label) {$a{$label[$n]}=$a[$n]}
		$a{daysleft}=$daysleft;
		push(@entries, \%a);
	} else {
		$d->{debug}=$line;
	}
}
$d->{entry}=\@entries;

parselastupdate(\$_);

2;
