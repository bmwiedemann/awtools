use strict;
my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
use DB_File;
#require "standard.pm";
my %relation;
my %timevalue=(second=>1, minute=>60, hour=>3600, day=>86400);
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

print "player feed<br>\n";
m,>\s*([^ <]+)(?: \(\d+[^)<]*\)</font>)?(?:<br><small>Premium Member</small>)?</b></center>,; my $name=$1;
if($name && m,Idle[^0-9\n]*(\d+|(?:N/A))(\s+seconds?|\s+minutes?|\s+hours?|\s+days?|),){
	my $idle="$1 $2";
	my $idlei=$1;
	my $timestr=$2; $timestr=~s/s$//; $timestr=~s/^\s*//;
	$idlei*=$timevalue{$timestr};
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)=gmtime();
	$hour+=$::options{tz};
	my $servertime=$hour*3600+$min*60+$sec;
        #print scalar gmtime(), " GMT ";#: $name idle:$1 $2  ";
	m,Local Time</td><td>(\d\d):(\d\d)</td></tr>,; my $localtime=($1*60+$2)*60+30;
	my $deliverytime=($servertime-$localtime);
	if($deliverytime<-24*60*60+50*60) {$deliverytime+=24*60*60}
	if($deliverytime<-60 || $deliverytime>50*60) {
		print "version outdated or wrong timezone?";
		exit(0);
	}
	$idlei+=$deliverytime;
	my $lastonline=time()-$idlei;
	my $inaccuracy=$timevalue{$timestr}+30;
	
        m,Logins</td><td>(\d+),; my $logins=$1;
	m,Playerlevel</a></td><td>(\d+ - \d+%)</td></tr>,; my $pl=$1;
#        my $points=0;
#        if(m,Rank \(Points Scored\)</td><td>([^<]*),){$points=$1};
#        m,Playerlevel</td><td>(\d+),; my $pl=$1;
        m,Sciencelevel</td><td>(\d+),; my $sl=$1;
        m,Culturelevel</td><td>(\d+),; my $cl=$1;
	#my $science="";
	my @science;
	foreach my $sci (@::sciencestr) {
		next if ! m,$sci</td><td>(\d+),; #$sci{$sci}=$1;
		#my $val=$1;
		push(@science,$1);
		#$sci=~/^(...)/;$sci=$1;
		#$science.=" $sci=$val";
	}
	if($debug){print "science: @science<br>\n";}
	my @race;
	{
		my $racere="";
		foreach my $r (@::racestr) {
			$racere.=qr"<li>[+-]\d+% $r \(([+-]\d)\)</li>";
		}
		if(/$racere/) {@race=($1,$2,$3,$4,$5,$6,$7);print "race: @race<br>\n"}
	}
	my $lastonlinegmt=gmtime($lastonline);
	print qq! <a href="relation?name=$name">name=$name</a> idle=$idle time=$localtime last=&quot;$lastonlinegmt&quot; logins=$logins pl=$pl sl=$sl cl=$cl\n<br>!;
	tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
	$name="\L$name";
	my $oldentry=$relation{$name};
	#if(!$oldentry) {$oldentry="4 UNKNOWN "}
	#$oldentry=~/(\d+ \w+ .*)(?=$::magicstring)(.*)/s; 
	#my ($rest,$magic)=($1,$2);
	#if($oldentry!~/$::magicstring/) {$magic=""; $rest=$oldentry;}
	#print "$dbname:$name $oldentry $rest + magic:$magic";
	#my $prevlogins="";
	#my $race="";
	#if($magic=~/(login:.*)/) {$prevlogins=$1." ";}
	#if($magic=~/(race:[-+,0-9]+)/) {$race=$1." ";}
	#if(!$race) {$race="race:".join(",",@race)." "}
	#my $newentry="${prevlogins}login:$logins:$lastonline+$inaccuracy";
#"${magicstring}";
	#chomp($rest);
	#$newentry="$rest\n${::magicstring}pl=$pl sl=$sl cl=$cl$science $race$newentry";
	my $newentry=addplayerir($oldentry, \@science, \@race, "$logins:$lastonline+$inaccuracy");
	if(!$debug) {$relation{$name}=$newentry;}
	else {print "<br>new:",$newentry;}
}

