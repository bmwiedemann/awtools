use strict;
use awparser;

if($::options{url}=~m{Alliance/$}) {
my @members=();
foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}gs) {
	if($line=~m/^"?#303030/) {
		my @a=split("</td><td>", $line);
		while(@a) {
			my($points,$x)=(shift(@a),shift(@a));
			$points=~s/.*>(\d+)/$1/s;
			if($x=~m{mode=post&u=(\d+)>([^<]+)</a>}) {
				push(@members, [int($points), int($1), $2]);
			}
		}
	} elsif($line=~m{^"#404040"><td>Name</td><td colspan="2">\s*<a href=(http://[^<]*)>([^<]*)</a></td>}) {
		$d->{url}=$1;
		$d->{name}=$2;
	} elsif($line=~m{^"#404040"><td>Points</td><td colspan="2">(\d+)</td>}) {
		$d->{points}=int($1);
	} elsif($line=~m{^"#404040"><td colspan="3">\(average of the Top (\d+)\)</td>}) {
		$d->{countingmembers}=int($1);
	} elsif($line=~m{^"#404040"><td colspan=4>Members - (\d+)</td>}) {
		$d->{members}=int($1);
	} elsif($line=~m{^"#404040"><td>Leader</td><td colspan="2"><a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a></td>}) {
		$d->{leader}=[int($1),$2];
	} elsif($line=~m{^"#404040"><td>Tag</td><td colspan="2"><a href=/rankings/alliances/\w+.php>(\w+)</a></td>}) {
		$d->{tag}=$1;
	} elsif($line=~m{^"#894900.*all incomings}) {
		$d->{premium}=1;
	} else {
		$d->{debug}=$line;
	}
}

$d->{members}=\@members;
}

# TODO: bool:isleader

2;
