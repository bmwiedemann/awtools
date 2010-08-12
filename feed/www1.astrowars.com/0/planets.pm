#use strict;
use DBAccess2;
use awstandard;
my $d=getparsed(\%::options);

#if(m!(?:Growth [+-]\d+%&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)?Production ([+-]\d+)%</td><td>(\d+)</td><td>\+(\d+)!) {
if($d->{hourlypp}) {
   my ($pp,$prodperh)=($d->{totalpp},$d->{hourlypp});
   my $dbh=get_dbh();
   my $sth=$dbh->prepare("UPDATE `internalintel` SET `production`=?, `pp`=? WHERE `alli`=? AND `pid`=?");
   $sth->execute($prodperh, $pp, $ENV{REMOTE_USER}, $::options{pid});
}

#exit 0; # dont use atm

if(0) {
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

my $name=$::options{name};
my $pid=playername2id($name);
if(!$pid) {print "user $name not found<br>\n";return 1}
print "user ".a({-href=>"relations?name=$name"},"$name($pid)").br;

my %own=();
my $planets=playerid2planets($pid);
foreach my $p (@$planets) {
	my @p=split("#",$p);
	#my $pp=$planets{$p[0]}[$p[1]-1];
	$own{$p}=1;
}

our %data;
#tie(%data, "DB_File", $dbname) or print "error accessing DB\n";

return unless /Production Points(.*)/s;
$_=$1;

my $nplanets=0;
my $nerrors=0;
for(;(@a=m!<tr[^>]*><td[^>]*><a [^>]*>([^<]+) (\d+)</a></td><td>(\d+)</td><td>(.*)!); $_=$a[3]) {
	my ($system,$planet,$pop)=@a[0..2];
        if($system=~/\((\d+)\)/) {$system=$1}
        elsif((my $x=systemname2id($system))) {$system=$x}
        else {print "unable to get ID of \"$system\"".br;$nerrors++;next}
        my $sid="$system#$planet";
        if($debug) {print "planet @a[0..2] : $sid\n".br;}
	$nplanets++;
	if($own{$sid}) {
		$own{$sid}=0;
		delete $own{$sid}; # strike out of lost-list cause still have
		next;
	}
   if($nplanets<3) {print "sanity check failed - not changing".br;last}
	print "new planet ".a({-href=>"system-info?id=$system"},$sid).br;
	my $entry=$data{$sid};
	my $newentry="5 $pid ";
	if(!$entry) {$entry=$newentry.gmtime()}
	else {$entry=~s/^[0-46-9] \d+ /$newentry/;}
	if($debug) {print "new: ".$entry.br;}
	else {$data{$sid}=$entry}
}

if($nerrors==0 && abs($nplanets-@$planets)<4) {
 foreach $sid (keys %own) {
	next unless($own{$sid});
	$sid=~/(\d+)#/;
	my $system=$1;
	print "lost planet ".a({-href=>"system-info?id=$system"},$sid).br;
	my $entry=$data{$sid};
	my $newentry="6 2 ";
	if(!$entry) {$entry=$newentry.gmtime()}
	else {$entry=~s/^[0-57-9] \d+ /$newentry/;}
	if($debug) {print "new: ".$entry.br;}
	else {$data{$sid}=$entry} # seemed to be buggy -> test
 }
}
}

# feed planet pop/pp
use awbuilding;


#if($::options{name} eq "greenbird"){
if(1){
	my $pid=$::options{pid};#playername2idm($::options{name});
	foreach my $p (@{$d->{planet}}) {
	my %h=(pp=>$p->{pp}, "pop"=>$p->{population},
		hf=>$p->{growth}-1, rf=>$p->{production}-int($p->{population}), 
		ownerid=>$pid);
#	print "<br>$p->{sid},$p->{pid},$p->{population}";
	update_building($p->{sid},$p->{pid},0,\%h);
	}
}

1;
