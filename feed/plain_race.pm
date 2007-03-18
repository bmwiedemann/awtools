use strict;
use awinput;

sub feed_plain_race() {
if(1 || $::options{name}=~m/greenbird/i) {
   if(m/^\s*(\w*)\s/s && playername2id($1)) { $::options{name}=$1 }
   else {return 1}
}
my $racere="";
my $sciencere="";
my @science;
my @race;
foreach my $r (@awstandard::racestr) {
	$racere.=qr"\*?\s*[+-]?\d+%\s+$r\s+\(([+-]?\d)\)\s*"s;
}
foreach my $sci (@awstandard::sciencestr) {
	$sciencere.=qr"$sci\s+(\d+)\s*"s;
}
#print "$_ $racere";
my $name=$::options{name};
if(@race=/$racere/) {
	print qq! <a href="relations?name=$::options{name}">name=$::options{name}</a> race: @race<br>\n!;
}
if(@science=/$sciencere/) {
	print "science: @science<br>\n";
}
if(@race || @science) {
	if(!playername2id($name)) {print "player $name not found<br>\n"}
   else { dbplayeriradd($name, \@science, \@race); }
}
}
1;
