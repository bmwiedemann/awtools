#package feed::fleet;
#use awinput;
#use CGI ":standard";

my $data=getparsed(\%::options);
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

my $name=$::options{name};
my $pid=playername2id($name);
if(!$pid) {print "user $name not found<br>\n";return 1}
print a({href=>"relations?name=$name"},"user $name($pid)").br;


dbfleetaddinit($pid, 1);
my @a;
for(;(@a=m!<tr[^>]*><td>([^<]+)</td><td>(?:<a href=/0/Map/.?.hl=(?:\d+)>)?<small>([^<]*)\s(\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
	my ($system,$planetid)=@a[1..2];
	if($debug) {print "moving ";}
	if($system=~/\((\d+)\)/) {$system=$1}
	elsif((my $x=systemname2id($system))) {$system=$x}
	else {print "unable to get ID of \"$system\" <br>";next}
	foreach(@a[6..7]){if(!$_){$_=0}}
	my @fleet=@a[3..7];
	my $details="@fleet";
	my $time=parseawdate($a[0]);
	my $sid="$system#$planetid";
	print "targeted: ".planetlink($sid)." $details<br>\n";
	dbfleetadd($system,$planetid,$pid, $name, $time, 3, \@fleet);
}


for(;(@a=m!<tr align=center bgcolor="#(\d{6})">(?:[^<]*(?:<[^s])*)*?<small>([^<]*) (\d+)</small>(?:</a>)?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>(.*)!); $_=$a[8]) {
	my ($color,$system,$planetid)=@a[0..2];
	if($system=~/\((\d+)\)/) {$system=$1}
	elsif((my $x=systemname2id($system))) {$system=$x}
	else {print "unable to get ID of \"$system\" <br>";next}
	my @fleet=@a[3..7];
	my $details="@fleet";
	my $sid="$system#$planetid";
   my $own=($color eq "404040")?1:0;
	print "defending $own fleet: ".planetlink($sid)." $details<br>\n";
	dbfleetadd($system,$planetid,$pid, $name, $time, $own, \@fleet);
}


# 2013: add stationary and moving fleets
foreach my $f (@{$data->{fleet}}, @{$data->{movingfleet}}) {
	my $system=$f->{sid};
	my $planetid=$f->{pid};
	my $own=!$f->{sieging};
	my $time=$f->{eta}||0;
	if($time) {$own=3}
	dbfleetadd($system,$planetid,$pid, $name, $time, $own, $f->{ship});
}
1;
