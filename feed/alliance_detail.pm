my $ironly=0;
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
	next if ! m,$sci</td><td>(\d+),;
	push(@science,$1);
}
my @race;
{
	my $racere="";
	foreach my $r (@::racestr) {
		$racere.=qr"<li>[+-]\d+% $r \(([+-]\d)\)</li>";
	}
	if(/$racere/) {@race=($1,$2,$3,$4,$5,$6,$7);}
}
my @prod;
foreach my $prod (qw(Production Science Culture)) {
	next if ! m,$prod</td><td>\+(\d+)/h,;
	push(@prod,$1);
}
if(m,Artifact</td><td>([^<]*)<,) {my $val=$1;$val=~s/ //;push(@prod,$val)}
if(m,Trade Revenue</td><td>(\d+)%,) {push(@prod,$1)}

my $oldentry=$relation{$name2};
my $newentry=addplayerir($oldentry,\@science,\@race,undef,undef,\@prod);
if($debug){ print "$oldentry @race @science @prod new:$newentry\n<br>" }
else {$relation{$name2}=$newentry}
untie %relation;

if($ironly){exit 0}


my @a;
# defending fleet
for(;(@a=m!<tr([^>]*)><td[^>]*>(\d+)</td><td>(\d+)</td>(?:<td>(?:\d+)</td>){6}<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
        my $system=$a[1];
        my $sid="$system#$a[2]";
        my @fleet=@a[3..7];
        my $details="@fleet";
	my $localname=$name;
	my $localpid=$pid;
	my $own=1;
	if($a[0]=~/602020/) {$localname="unknown"; $localpid=2; $own=0; }
        print "defending fleet: ".planetlink($sid)." $details<br>\n";
        my $oldentry=$data{$sid};
        my $newentry=addfleet($oldentry,$localpid, $localname, $time, $own, \@fleet);
        if(!$debug){$data{$sid}=$newentry;}
        else {if($newentry){print "$sid $newentry<br>\n"}}
}

# own fleets on foreign planet
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

# flying fleets
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
