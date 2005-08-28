use strict;
use DB_File;
my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";

if(0 && $::options{name}=~m/BananaBird/i) {
   if(m/^\s*(\w*)\s/s) { $::options{name}=$1 }
   else {return 1}
}
my $racere="";
my $sciencere="";
my @science;
my @race;
foreach my $r (@::racestr) {
	$racere.=qr"\*?\s*[+-]?\d+%\s+$r\s+\(([+-]?\d)\)\s*"s;
}
foreach my $sci (@::sciencestr) {
	$sciencere.=qr"$sci\s+(\d+)\s*"s;
}
#print "$_ $racere";
my $name="\L$::options{name}";
if(@race=/$racere/) {
	print qq! <a href="relations?name=$::options{name}">name=$::options{name}</a> race: @race<br>\n!;
}
if(@science=/$sciencere/) {
	print "science: @science<br>\n";
}
if(@race || @science) {
	my %relation;
	require "input.pm";
	if(!playername2id($name)) {print "player $name not found<br>\n"; exit 0;}
	tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
	my $oldentry=$relation{$name};
	my $newentry=addplayerir($oldentry, \@science, \@race);
	if($::options{debug}) {print $newentry}
	else {$relation{$name}=$newentry}
	exit 0;
}
1;
