my $debug=$::options{debug};
print "alliance_detail\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
my $dbname2="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
use DB_File;
require "./input.pm";
if(!/<tr><td><center>([^<]*)<br>/) {return 1;}
my $name=$1;
my $pid=playername2id($name);
if(!$pid) {print "user $name not found<br>\n";return 1}
print qq!user <a href="relations?name=$name">$name($pid)</a><br>\n!;
my $name2="\L$name";

our %data;
tie(%data, "DB_File", $dbname) or print "error accessing DB\n";
my %data2;
tie(%relation, "DB_File", $dbname2) or print "error accessing DB\n";

#my $science="";
my @science;
foreach my $sci (@::sciencestr) {
	next if ! m,$sci</td><td>(\d+),; #$sci{$sci}=$1;
	my $val=$1;
	push(@science,$val);
	#$sci=~/^(...)/;$sci=$1;
	#$science.=" $sci=$val";
}
my @race;
{
	my $racere="";
	foreach my $r (@::racestr) {
		$racere.=qr"<li>[+-]\d+% $r \(([+-]\d)\)</li>";
	}
	if(/$racere/) {@race=($1,$2,$3,$4,$5,$6,$7);}
}
my $oldentry=$relation{$name2};
my $newentry=addplayerir($oldentry,\@science,\@race);
if($debug){ print "$oldentry @race @science new:$newentry\n<br>" }
else {$relation{$name2}=$newentry}
untie %relation;


my @a;
for(;(@a=m!<tr[^>]*><td[^>]*>(\d+)</td><td>(\d+)</td>(?:<td>(?:\d+)</td>){6}<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[7]) {
        my $system=$a[0];
        my $sid="$system#$a[1]";
        my @fleet=@a[2..6];
        my $details="@fleet";
        print "defending fleet: ".planetlink($sid)." $details<br>\n";
        my $oldentry=$data{$sid};
        my $newentry=addfleet($oldentry,$pid, $name, $time, 1, \@fleet);
        if(!$debug){$data{$sid}=$newentry;}
        else {if($newentry){print "$sid $newentry<br>\n"}}
}

for(;(@a=m!<tr[^>]*><td[^>]*>(\d+)</td><td>(\d+)</td><td>(\d+)</td>(?:<td>N/A</td>){5}<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
	my $sid="$a[0]#$a[1]";
	my @fleet=@a[3..7];
	my $details="@fleet";
	my $oldentry=$data{$sid};
	my $time=undef;
	my $newentry=addfleet($oldentry,$pid, $name, $time, 0, \@fleet);
	if(!$debug){$data{$sid}=$newentry;}
	else {print "$sid $newentry<br>\n"}
}
for(;(@a=m!<tr[^>]*><td[^>]*>(\d+)</td><td>(\d+)</td><td colspan=[^>]*>([^<]*)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)(.*)!); $_=$a[8]) {
	my $sid="$a[0]#$a[1]";
	my @fleet=@a[3..7];
	my $details="@fleet";
	print "targeted: ".planetlink($sid)." $details <br>\n";
	my $oldentry=$data{$sid};
	my $time=parseawdate($a[2]);
	my $newentry=addfleet($oldentry,$pid, $name, $time, 0, \@fleet);
	if(!$debug){$data{$sid}=$newentry;}
	else {print "$sid $newentry<br>\n"}
}
require 'feed/libincoming.pm';
parseincomings($_);
print "<br>done\n";
1;
