use strict;
use awstandard;
use dbaddpl;
# feed in-game player profile to DBs
my $data=getparsed(\%::options);
awinput::updateplayer($data);

my %timevalue=(""=>1, second=>1, minute=>60, hour=>3600, day=>86400);
my %accuracytimevalue=(""=>86398, second=>1, minute=>60, hour=>3600, day=>86400);
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

my $name=$data->{name};
if($name && $data->{idle}){
	$data->{idle}=~m,(\d+|(?:N/A))(\s+seconds?|\s+minutes?|\s+hours?|\s+days?|),;
	my $idle="$1 $2";
	my $idlei=$1;
	my $timestr=$2; $timestr=~s/s$//; $timestr=~s/^\s*//;
	$idlei=~s!N/A!1!;
	$idlei*=$timevalue{$timestr};
	#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)=gmtime();
	#$hour+=$::options{tz};
	#my $servertime=$hour*3600+$min*60+$sec;
        #print scalar gmtime(), " GMT ";#: $name idle:$1 $2  ";
#	m,Local Time</td><td>(\d\d):(\d\d)</td></tr>,; my $localtime=($1*60+$2)*60+30;
	#my $localtime=$::time[0]*3600+$::time[1]*60+$::time[2];
	#my $deliverytime=($servertime-$localtime);
	#if($deliverytime<(-24*60+50)*60) {$deliverytime+=24*60*60}
	if($::deliverytime<-60 || $::deliverytime>50*60) {
		print "version outdated or wrong timezone? (delivery $::deliverytime seconds)";
		goto end;
	}
	my $lastonline=time()-$idlei-$::deliverytime;
	my $inaccuracy=$accuracytimevalue{$timestr}+1;
	
	my $logins=$data->{logins};
	my $pl=$data->{playerlevel};
	#$pl=~s/^(\d+).*/$1/;
	my $sl=$data->{sciencelevel};
	my $cl=$data->{cultuelevel};
	my @science;
	foreach my $sci (@awstandard::sciencestr) {
		push(@science,$data->{lc($sci)});
	}
	if($debug){print "science: @science<br>\n";}
	my @race;
	if($data->{racevalue}) {
		@race=@{$data->{racevalue}};
	}
	#print "race=@race<br>\n";
	my $lastonlinegmt=gmtime($lastonline);
	print qq! <a href="relations?name=$name">name=$name</a> idle=$idle last=&quot;$lastonlinegmt&quot; logins=$logins pl=$pl sl=$sl cl=$cl\n<br>!;
#tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
#	$name="\L$name";
   dbplayeriradd($name, \@science, \@race, [$logins,$lastonline,$idlei,$inaccuracy]);
   if(lc($name) ne lc($::options{name})) {
      dbaddpl(time()-$::deliverytime, $name, $pl);
      #system("/home/aw/inc/dbaddpl", time()-$::deliverytime, $name, $pl);
   }
#	my $oldentry=$relation{$name};
#	my $newentry=addplayerir($oldentry, \@science, \@race, [$logins,$lastonline,$idlei,$inaccuracy]);
#	if(!$debug) {$relation{$name}=$newentry;}
#	else {print "<br>new:",$newentry;}
	use awsql;
	my $prem=$data->{premium};
	update_premium($data->{pid}, $prem);
}


end:
1;
