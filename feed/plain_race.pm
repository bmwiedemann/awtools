package feed;
use strict;
use awstandard;
use awinput;

sub feed_plain_race() {
   # match plain incomings, too
   if(/(\d\d:\d\d:\d\d - \w{3} \d\d)\s*Attention !!! We have evidence of an incoming fleet around that time([^!]+)going to attack ([^!]+)\s*\[(\d+)\]\s*(\d+)!\s*We suppose its the Fleet of (.*)\./s) {
      my ($awdatetime,$fleets,$targetname,$systemid,$planetid,$ename)=($1,$2,$3,$4,$5,$6);
      my $time=parseawdate($awdatetime);
      my @fleet;
      my $shipn=0;
      # colony ships are not shown in incomings
      foreach my $ship (qw(Transports ColonyShip Destroyer Cruiser Battleship)) {
         if($fleets=~/(\d+) $ship/) {
            $fleet[$shipn]=$1;
         } else {$fleet[$shipn]=0}
         $shipn++;
      }
      $ename=~s/^\[[a-zA-Z]{1,4}\] //;
      my $epid=playername2id($ename);
      print "$time @fleet,$targetname,$systemid,$planetid,$ename,$epid\n<br>";
      if(!$::options{debug}) {
         dbfleetaddinit(undef, 0);
         my $res=dbfleetadd($systemid,$planetid,$epid, $ename, $time, 2, \@fleet);
         dbfleetaddfinish();
         print "added<br>";
      }
   }

# for plain race feeding we expect a name right at the beginning
if(1 || $::options{name}=~m/greenbird/i) {
   if(m/^\s*(?:\[\w+\] )?(\w+)\s/s && playername2idm($1)) { $::options{name}=$1 }
   else {return 1}
}
my $racere="";
my $sciencere="";
my @science;
my @race;
foreach my $r (@awstandard::racestr) {
	if($r eq "speed") {
		$racere.=qr"\*?\s*\+[0-9.]+h\s+$r\s+\(([+-]?\d)\)\s*"s;
		next;
	}
	$racere.=qr"\*?\s*[+-]?\d+%\s+$r\s+\(([+-]?\d)\)\s*"s;
}
foreach my $sci (@awstandard::sciencestr) {
   if($sci eq "Trade Revenue") {$sciencere.=qr"(?:$sci\s+(\d+))?"s;}
	else { $sciencere.=qr"$sci\s+(\d+)\s*"s; }
}
#print "$_ $racere";
my $name=$::options{name};
if(@race=/$racere/) {
	print qq! <a href="relations?name=$::options{name}">name=$::options{name}</a> race: @race<br>\n!;
}
if(!@race && (@race=/([-+][0-4])([-+][0-4])([-+][0-4])([-+][0-4])([-+][0-4])([-+][0-4])([-+][0-4])\.\+\d\d\d \d+d/)) {
	print "found AWTools style race @race</br>";
}
if(@science=/$sciencere/) {
	print "science: @science<br>\n";
}
if(@race || @science) {
	my $time=time-3600*24*300;
	if(m/age\s+(\d+)/) {$time=time-3600*24*$1; print "age: $1 days<br>\n";}
	if(!playername2idm($name)) {print "player $name not found<br>\n"}
   else { dbplayeriradd($name, \@science, \@race, undef, undef, undef, $time); }
}
}
1;
