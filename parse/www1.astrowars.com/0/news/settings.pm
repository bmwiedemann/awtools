use strict;
use awparser;

foreach my $line (m{<tr><td bgcolor='#404040'>(.+?)</tr>}gs) {

	if($line=~m{Email Address.*value="([^"]*)"}) {
		$d->{emailaddress}=$1;
	} elsif($line=~m{Glossary Language<br>.*value="([-0-9]+)" CHECKED}s) {
		$d->{language}=int($1);
	} elsif($line=~m{Preview<br>.*value="([-0-9]+)" CHECKED}s) {
		$d->{preview}=int($1);
	} elsif($line=~m{name="zeitdifferenz" size="8" class=text value="([^"]*)"}) {
		$d->{timediff}=int($1);
	} elsif($line=~m{name="icq" size="8" class=text value="([^"]*)"}) {
		$d->{icq}=int($1);
	} elsif($line=~m{Combat Value.*value="([^"]*)"}) {
		$d->{mincv}=int($1);
	} elsif($line=~m{password</td>}) {
	} else {
		$d->{debug}=$line;
	}
}

2;
