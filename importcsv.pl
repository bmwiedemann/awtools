#!/usr/bin/perl -w

use MLDBM;
use Fcntl;
use strict;
our (%alliances,%starmap,%player,%playerid,%planets);
tie %alliances, "MLDBM", "newdb/alliances.mldbm", O_RDWR|O_CREAT, 0666 or die $!;
tie %starmap, "MLDBM", "newdb/starmap.mldbm", O_RDWR|O_CREAT, 0666;
tie %player, "MLDBM", "newdb/player.mldbm", O_RDWR|O_CREAT, 0666;
tie %playerid, "MLDBM", "newdb/playerid.mldbm", O_RDWR|O_CREAT, 0666;
tie %planets, "MLDBM", "newdb/planets.mldbm", O_RDWR|O_CREAT, 0666;
my @origin;
#my @playersat; # who has planets at ID
my @playerplanets; #where does he have his
my @alliancemembers; #who is member
my %tempplanets;
my $firstline;
my (@elements);
sub dumphash { my ($h)=@_;
	foreach(keys %$h) {
		print "$_=$$h{$_}\n";
	}
}
sub starmap { my($x,$y,$level,$id,$name)=@_;
	my %h=("x"=>$x, "y"=>$y, "level"=>$level, "name"=>$name, "origin" => \@{$origin[$id]});
	$starmap{$id}=\%h;
	$starmap{"\L$name"}=$id;
	$starmap{"$x,$y"}=$id;
}
sub alliances {
	my %h=();
	my $id;
#	if($firstline) { splice(@elements,5,1); }
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "tag") {$alliances{"\L$_[$i]"}=$id}
	}
	$h{m}=$alliancemembers[$id];
	$alliances{$id}=\%h;
}
sub player { #rank points id science culture level home_id logins from joined alliance name
	my %h=();
	my $id;
#	splice(@_,7,1);
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "name") {$playerid{"\L$_[$i]"}=$id}
		if($elements[$i] eq "home_id") { push @{$origin[$_[$i]]}, $id; }
	}
	$h{planets}=$playerplanets[$id];
	push(@{$alliancemembers[$h{alliance}]},$id);
	$player{$id}=\%h;
}

sub planets {
	my %h=();
	my ($id,$pid);
	if($firstline) { #splice(@elements,2,1); }
		$elements[3]=~s/starbase/sb/;
		$elements[2]=~s/population/pop/;
		$elements[5]=~s/siege/s/;
	}
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "planetid") {
			$pid=$_[$i];
	#		if($planets{$id} && $planets{$id}[$pid]) {
	#			$h{c}=$planets{$id}[$pid]{c}; 
	#		}
		}
		if($elements[$i] eq "systemid") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "ownerid") { 
			push(@{$playerplanets[$_[$i]]}, "$id#$pid");
#			push(@{$playersat[$id]}, $_[$i]) 
		}
	}
#	$planets{"$id#$pid"}=\%h;
	my @temp=$planets{$id}?@{$planets{$id}}:();
	$temp[$pid-1]=\%h;
	$planets{$id}=\@temp;
#	$tempplanets{$id}[$pid-1]=\%h;
}

print "reading CSV files\n";
#for my $f (@::files) {
for my $f (qw(planets player alliances starmap)) {
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
	if($f eq "planets") {
#		while(my @a=each(%tempplanets)) {
#			$planets{$a[0]}=\@{$a[1]};
#		}
	}
#	if($f eq "player") {
#		print "indexing origins\n";
#		while(my @a=each(%player)) {
#			my $origin=$a[1]{home_id};
#			push @{$origin[$origin]}, $a[0];
#		}
#	}
}
#print "indexing origins\n";
#while(my @a=each(%player)) {
#	my $origin=$a[1]{home_id};
#	print "$a[0],$origin\n";
#	$starmap{$origin}{origin}.=$a[0]." ";
#	exit 0;
#}
#my $x=$starmap{$starmap{"0,0"}};
#my $x=$alliances{$alliances{"TGD"}};
#my $x=$player{49545};
#foreach(keys(%$x)) {
#	print "$_ = $$x{$_}\n";
#}
#print $playerid{"greenbird"},"\n";
#print "@{$::starmap{480}{origin}}";

#foreach(@alliancemembers) { next unless $_; print "@$_\n"; }

print "done\n";
1;
