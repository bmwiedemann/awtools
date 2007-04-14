use strict;
use awinput;

sub feed_plain_race() {
   # match plain incomings, too
   if(/(\d\d:\d\d:\d\d - \w{3} \d\d)\s*Attention !!! We have evidence of an incoming fleet around that time([^!]+)going to attack ([^!]+)\s*\[(\d+)\]\s*(\d+)!\s*We suppose its the Fleet of (.*)\./s) {
      my ($awdatetime,$fleets,$targetname,$systemid,$planetid,$ename)=($1,$2,$3,$4,$5,$6);
      my $time=parseawdate($awdatetime);
      my @fleet;
      my $shipn=0;
      # colony ships are not shown in incomings
      foreach my $ship (qw(Transports Destroyer Cruiser Battleship)) {
         if($fleets=~/(\d+) $ship/) {
            $fleet[$shipn]=$1;
         }
         $shipn++;
      }
      $ename=~s/^\[[a-zA-Z]{1,4}\] //;
      my $epid=playername2id($ename);
      print "$time @fleet,$targetname,$systemid,$planetid,$ename,$epid\n<br>";
      if(!$::options{debug}) {
         dbfleetaddinit(undef, 0);
         my $res=dbfleetadd($systemid,$planetid,$epid, $ename, $time, 2, \@fleet);
         dbfleetaddfinish();
      }
   }

# for plain race feeding we expect a name right at the beginning
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
