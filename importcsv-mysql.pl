#!/usr/bin/perl -w
use strict;

use DBAccess;
if(!$dbh) {die "DB err: $!"}

our (%alliances,%starmap,%player,%playerid,%planets,%alltrades,%battles,%prices,%baseprices);
our @opop;
my $firstline;
my (@elements);
sub dumphash { my ($h)=@_;
	foreach(keys %$h) {
		print "$_=$$h{$_}\n";
	}
}

sub prices {
   for(my $i=0; $i<=$#elements; ++$i) {
      my $e=lc($elements[$i]);
      $e=~s/ //;
      $_[$i]=~s/,/./;
      $prices{$e}=$_[$i];
      if(not ($baseprices{$e})) {$baseprices{$e}=$_[$i];}
   }
}

sub battles {
        my %h=();
        my $id;
#       splice(@_,7,1);
        for(my $i=0; $i<=$#elements; ++$i) {
                if($elements[$i] eq "id") {$id=$_[$i]}
                else {$h{$elements[$i]}=$_[$i];}
        }
        $battles{$id}=\%h;
}

sub starmap { my($x,$y,$level,$id,$name)=@_;
	if(!$name) {print "$x $y\n"; $name="undefined"}
	$name=~s/\s+/ /;
	my %h=("x"=>$x, "y"=>$y, "level"=>$level, "name"=>$name);
	$starmap{$id}=\%h;
#	$starmap{"\L$name"}=$id;
#	$starmap{"$x,$y"}=$id;
}
sub alliances {
	my %h=();
	my $id;
#	if($firstline) { splice(@elements,5,1); }
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		#if($elements[$i] eq "tag") {$alliances{"\L$_[$i]"}=$id}
	}
	#$h{m}=$alliancemembers[$id];
	$alliances{$id}=\%h;
}

my @arank;
sub player { #rank points id science culture level home_id logins from joined alliance name
	my %h=();
	my $id;
#	splice(@_,7,1);
	if($firstline) {
		$elements[8]=~s/from/country/;
	}
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "name") {$playerid{"\L$_[$i]"}=$id}
#		if($elements[$i] eq "home_id") { push @{$origin[$_[$i]]}, $id; }
	}
#	$h{planets}=$playerplanets[$id];
#	push(@{$alliancemembers[$h{alliance}]},$id);
   if(my $aid=$h{alliance}) {
      # this only works because player.csv is sorted by rank
      $h{arank}=++$arank[$aid];
   }
   $h{opop}=$opop[$id]||0;
	$player{$id}=\%h;
}

sub planets {
	my %h=();
	my ($id,$pid);
	if($firstline) { #splice(@elements,2,1); }
#		$elements[3]=~s/starbase/sb/;
#		$elements[2]=~s/population/pop/;
#		$elements[5]=~s/siege/s/;
	}
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "planetid") {
			$pid=$_[$i];
	#		if($planets{$id} && $planets{$id}[$pid]) {
	#			$h{c}=$planets{$id}[$pid]{c}; 
	#		}
		}
		if($elements[$i] eq "systemid") {$id=$_[$i]}
		{$h{$elements[$i]}=$_[$i];}
	}
	$h{opop}=$h{population};
   $opop[$h{ownerid}]+=$h{opop}; # used in player
	my $sidpid=$id*13+$pid;
	$planets{"$sidpid"}=\%h;
#	my @temp=$planets{$id}?@{$planets{$id}}:();
#	$temp[$pid-1]=\%h;
#	$planets{$id}=\@temp;
#	$tempplanets{$id}[$pid-1]=\%h;
}

my $tid=0;
# in DB there is always pid1>pid2
sub alltrades
{
   my($pid1,$pid2)=@_;
   if($pid1<$pid2) { ($pid2,$pid1)=@_ }
   $alltrades{$tid++}={pid1=>$pid1, pid2=>$pid2};
}


# main import code starts here

print "reading CSV files\n";
#for my $f (@::files) {
for my $f (qw(planets player alliances starmap alltrades battles prices)) {
	my $file="$f.csv";
	my $head=1;
	$firstline=1;
	print "\t$file\n";
	open(F, $file) or die "could not open $file: $!";
	while(<F>) {
		chomp();
		next if(/^\s*$/);
		my @a=split ("\t", $_);
		if($head) {
			@elements=@a;
			$head=0;
			next;
		}
		#print "$f $_\n";
		no strict "refs";
		&$f(@a);
		use strict "refs";
		$firstline=0;
	}
}

print "pushing into MySQL DB\n";
use Tie::DBI;
if(1){
print "\tplanets\n";
my %h;
tie %h,'Tie::DBI',$dbh,'planets','sidpid',{CLOBBER=>3};
%h=%planets;
untie %h;
print "\tplayer\n";
tie %h,'Tie::DBI',$dbh,'player','pid',{CLOBBER=>3};
%h=%player;
untie %h;
print "\talliances\n";
tie %h,'Tie::DBI',$dbh,'alliances','aid',{CLOBBER=>3};
%h=%alliances;
untie %h;
print "\tstarmap\n";
tie %h,'Tie::DBI',$dbh,'starmap','sid',{CLOBBER=>3};
%h=%starmap;
untie %h;


print "\tadding battles\n";
tie %h,'Tie::DBI',$dbh,'battles','id',{CLOBBER=>1};
#%h=%battles; # battles.csv only delivers incremental data
while(my @a=each(%battles)) {
   $h{$a[0]}=$a[1];
}
untie %h;
print "\tmerging trades\n";
my $now=time();
my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `trades` VALUES (?, ?, ?)!);
while(my @a=each(%alltrades)) {
   my %a=%{$a[1]};
#   next if $prevtrades{"$a{pid1},$a{pid2}"}; # skip dups
   my $result=$sth->execute($a{pid1}, $a{pid2}, $now);
}
$sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `alltrades` VALUES ('',?, ?)!);
my $trades=$dbh->selectall_arrayref("SELECT pid1,pid2 FROM `trades`");
foreach my $row (@$trades) {
   $sth->execute($row->[0], $row->[1]);
   $sth->execute($row->[1], $row->[0]);
}
system("hourly/otr.pl");

#$dbh->do("UPDATE `tradelive` SET trade=(SELECT trade FROM player WHERE player.pid=tradelive.pid)");
$sth=$dbh->prepare(qq!REPLACE INTO `tradelive` VALUES (?,?)!);
while(my @a=each(%player)) {
   $sth->execute($a[0], $a[1]->{trade});
}

if(0) {
   print "\talltrades\n";
   tie %h,'Tie::DBI',$dbh,'alltrades','tid',{CLOBBER=>3};
   %h=%alltrades;
   untie %h;
   $dbh->do("OPTIMIZE TABLE `alltrades`");
}



print "\tmerging playerextra\n";
$sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', NULL)!);
while(my @a=each(%player)) {
   my $p=$a[1];
#   print "$a[0], $p->{name}\n";
   my $result=$sth->execute($a[0], $p->{name});
}

# re-export:
if(1){
   system("./playertradecheck.pl");
   my $prevtrades=$dbh->selectall_arrayref("SELECT pid1,pid2 FROM `trades`");
   open(F, ">", "html/alltrades.csv");
   print F "id1\tid2\n";
   foreach(@$prevtrades) {
      print F join("\t",@$_),"\n";
   }
}

}

print "updating player.joinn\n";
my $res=$dbh->selectall_arrayref("SELECT `pid` FROM `player` ORDER BY `joined` ASC");
my $sth=$dbh->prepare_cached(qq!UPDATE `player` SET `joinn` = ? WHERE `pid` =?!);
my $n=0;
foreach my $row (@$res) {
   my($pid)=@$row;
   $sth->execute(($n++), $pid);
}


print "\tprices\n";
$sth=$dbh->prepare("REPLACE INTO `prices` VALUES (?,?)");
delete($prices{date});
delete($baseprices{date});
for my $p (keys %prices) {
   $sth->execute($p,$prices{$p});
}
for my $p (keys %baseprices) {
   $sth->execute("b$p",$baseprices{$p});
}

print "done\n";
1;
