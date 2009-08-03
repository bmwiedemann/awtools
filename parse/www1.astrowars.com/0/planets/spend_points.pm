use strict;
use awparser;
my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab");

if(m{Where to spend a <a href=/0/Glossary//\?id=33>Supply Unit</a>\? \((\d+)\)}) {
	$d->{su}=int($1);
	for my $v (@buildings) {
		my $key=lc($v); $key=~s/ //;
		(my $a)=(m/$v <br>get \$(\d+)<\/td>/);
		$d->{"su$key"}=int($a);
	}
}

2;
