my $debug=$::options{debug};
use Time::Local;
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

my %data;
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
for(;(@a=m!<tr[^>]*><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>(?:<td>N/A</td>){5}<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
	my $sid="$a[0]#$a[1]";
	my $details="@a[3..7]";
	my $oldentry=$data{$sid};
	my $time=gmtime();
	if($oldentry=~/$details/){$oldentry=~s/^3 $pid /4 $pid /;next}
	my $newentry=$oldentry||"4 $pid";
	print "sieged: ".planetlink($sid)." $details<br>\n";
	$details="automagic:$name:$time $details";
	$newentry.=" $details";
	if(!$debug){$data{$sid}=$newentry;}
	else {print "$sid $newentry<br>\n"}
}
for(;(@a=m!<tr[^>]*><td>(\d+)</td><td>(\d+)</td><td colspan=[^>]*>([^<]*)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)(.*)!); $_=$a[8]) {
	my $sid="$a[0]#$a[1]";
	my $details="@a[3..7]";
	print "targeted: ".planetlink($sid)." $details <br>\n";
	my $oldentry=$data{$sid};
	my $time=parseawdate($a[2]);
	$time=gmtime($time-3600*$::options{tz});
	$details="automagic:$name:$time $details";
	#print "old: ",$oldentry;
	my $newentry=$oldentry||"3 $pid";
	if($oldentry=~/$details/) {next}
	$newentry.=" $details";
	#print "new: $newentry<br>";
	if(!$debug){$data{$sid}=$newentry;}
}
for(;(@a=m!([^>]*)</td><td[^>]*> <b>Attention(.*?) going to attack <b>([^<]+)</b>.<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/\?id=(\d+)>([^<]+)</a>((?:[^>]*</td><td[^>]*> <b>Attention)?.*)!);$_=$a[5]) {
	my @ship=(0,0,0,0,0);
	my $pid=$a[3];
	my $sid;
	my $shipn=0;
	foreach my $ship (qw(Transports Colony Destroyer Cruiser Battleship)) {
		if($a[1]=~/(\d+) $ship/) {
			$ship[$shipn]=$1;
		}
		$shipn++;
	}
	my $time=parseawdate($a[0]);
	$time=gmtime($time-3600*$::options{tz});
	if($a[2]=~/(.+) (\d+)$/) {
		$sid=systemname2id($1);
		if($sid){$sid.="#$2"}
	}
	if(!$sid) {next}
	my $oldentry=$data{$sid};
	my $newentry;
	my $details="automagic:$a[4]:$time @ship";
	if($oldentry=~/$details/) {next}
	if($oldentry) {$newentry=$oldentry." ".$details}
	else {$newentry="3 $pid ".$details}
	print "incoming: ".planetlink($sid)." @ship<br>\n";
	#print " old:$oldentry new:$newentry<br>\n";
	if(!$debug){$data{$sid}=$newentry;}
}
1;
