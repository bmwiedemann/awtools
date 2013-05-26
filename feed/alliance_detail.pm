use strict;
package feed::alliance_detail;
use awstandard;
use awinput;
use awbuilding;
my $ironly=0;
my $debug=1;#$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

my $data=getparsed(\%::options); # costs ~5ms
if(0 && $::options{name} eq "greenbird"){
	my $pid=$::options{pid};
	foreach my $p (@{$data->{planet}}) {
		my %h=("pop"=>$p->{"pop"},
      hf=>$p->{hf}, rf=>$p->{rf}, gc=>$p->{gc}, rl=>$p->{rl}, sb=>$p->{sb},
      ownerid=>$pid);
		update_building($p->{sid},$p->{pid},0,\%h); # costs 60ms
	}
}

my $name=$data->{name};
if(!$data->{name}) {return 1;}
my $pid=$data->{pid};
if(!$pid) {print "user $name not found<br>\n";return 1}
print qq!user <a href="relations?name=$name">$name($pid)</a><br>\n!;
my $name2="\L$name";

my @science;
foreach my $sci (@awstandard::sciencestr) {
	push(@science, $data->{lc($sci)}{value});
}
my @race;
{
	foreach my $r (@awstandard::racestr) {
		push(@race, $data->{"race".lc($r)}{n});
	}
}
my @prod;
foreach my $prod (qw(Production Science Culture Artifact Traderevenue AD PP)) {
	push(@prod,$data->{lc($prod)}{value});
}
#if(m,Artifact</td><td>([^<]*)<,) {my $val=$1;$val=~s/ //;push(@prod,$val)}
#if(m,Trade Revenue</td><td>(\d+)%,) {push(@prod,$1)}
#foreach my $resource (qw(AD PP)) {
#   next if ! m,$resource</td><td>(-?\d+),;
#   push(@prod,$1);
#}

my @trade;
if($data->{tradeagreement}) {
   my @tpid;
   foreach my $t (@{$data->{tradeagreement}}) {
      push(@trade,$t->{name});
      my $tpid=$t->{pid};
      next if not $tpid;
      push(@tpid,$tpid);
   }
   print "<br>trades: @trade<br>";
   awinput::add_trades($pid,\@tpid);
}

if($debug) {
	print "science:@science race:@race prod:@prod<br>";
}


dbplayeriradd($name2, \@science,\@race,undef,\@trade,\@prod);
#my $oldentry=$relation{$name2};
#my $newentry=addplayerir($oldentry,\@science,\@race,undef,undef,\@prod);
#if($debug){ print "$oldentry @race @science @prod new:$newentry\n<br>" }
#else {$relation{$name2}=$newentry}
#untie %relation;

if(!$ironly){

dbfleetaddinit($pid, 3);
my @a;
# defending fleet
foreach my $p (@{$data->{planet}}) {
#for(;(@a=m!<tr([^>]*)><td[^>]*>(\d+)</td><td>(\d+)</td>(?:<td>(?:\d+)</td>){6}<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
        my ($system,$planetid)=($p->{sid},$p->{pid});
        my $sid="$system#$planetid";
        my @fleet=@{$p->{ship}};
        my $details="@fleet";
	my $localname=$name;
	my $localpid=$pid;
	my $own=1;
	if($p->{siege}) {
		if($p->{foreignplanet}) {$own=0} # we siege someone
		else	{$localname="unknown"; $localpid=2; $own=0; } # someone sieges us
	}

        print "defending fleet: ".planetlink($sid)." $details<br>\n";
        dbfleetadd($system,$planetid,$localpid, $localname, undef, $own, \@fleet);
}

# flying fleets
foreach my $f (@{$data->{movingfleet}}) {
#for(;(@a=m!<tr[^>]*><td[^>]*>(\d+)</td><td>(\d+)</td><td colspan=[^>]*>([^<]*)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)(.*)!); $_=$a[8]) {
        my ($system,$planetid)=($f->{sid},$f->{pid});
        my $sid="$system#$planetid";
	my @fleet=@{$f->{ship}};
	my $time=$f->{eta};
	my $details="@fleet $time";
	print "targeted: ".planetlink($sid)." $details <br>\n";
	dbfleetadd($system,$planetid,$pid, $name, $time, 3, \@fleet);
}
require 'feed/libincoming.pm';
#feed::libincoming::parseincomings($_);
print "inco: @{$data->{incoming}}<br>";
feed::libincoming::feedincomings($data->{incoming});
dbfleetaddfinish();

print "<br>done\n";
}

1;
