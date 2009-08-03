use strict;
use awparser;
my @buildings=("Hydroponic Farm", "Robotic Factory", "Galactic Cybernet", "Research Lab");

for my $v (@buildings) {
	my $key=lc($v); $key=~s/ //;
   ($d->{"su$key"})=(m/$v <br>get \$(\d+)<\/td>/);
}

2;
