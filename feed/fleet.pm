my $debug=$::options{debug};
use Time::Local;
print "fleet\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
#my $dbname2="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
use DB_File;
require "./input.pm";
my $name=$::options{name};
my $pid=playername2id($name);
if(!$pid) {print "user $name not found<br>\n";return 1}
print qq!user <a href="relations?name=$name">$name($pid)</a><br>\n!;
my $name2="\L$name";

my %data;
tie(%data, "DB_File", $dbname) or print "error accessing DB\n";



my @a;
for(;(@a=m!<tr[^>]*><td>([^<]+)</td><td><a href=/0/Map/.?.hl=(\d+)><small>[^<]*(\d+)</small></a></td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
	my $sid="$a[1]#$a[2]";
	foreach(@a[6..7]){if(!$_){$_=0}}
	my @fleet=@a[3..7];
	my $details="@fleet";
	my $oldentry=$data{$sid};
	my $time=parseawdate($a[0]);
	#$time=gmtime($time-3600*$::options{tz});
#	my $newentry=$oldentry||"3 $pid";
	print "targeted: ".planetlink($sid)." $details<br>\n";
#	$details="automagic:$name:$time $details";
#	$newentry.=" $details";
	my $newentry=addfleet($oldentry,$pid, $name, $time, 2, \@fleet);
	if(!$debug){$data{$sid}=$newentry;}
	else {print "$sid $newentry<br>\n"}
}
for(;(@a=m!<small>([^<]*) (\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[7]) {
	my $system=$a[0];
	if($system=~/\((\d+)\)/) {$system=$1}
	elsif((my $x=systemname2id($system))) {$system=$x}
	else {print "unable to get ID of $system <br>";next}
	my $sid="$system#$a[1]";
	my @fleet=@a[2..6];
	my $details="@fleet";
	print "defending fleet: ".planetlink($sid)." $details<br>\n";
	my $oldentry=$data{$sid};
	my $newentry=addfleet($oldentry,$pid, $name, $time, 1, \@fleet);
        if(!$debug){$data{$sid}=$newentry;}
        else {print "$sid $newentry<br>\n"}
}

1;
