#!/usr/bin/perl -w

use strict "vars";
our (%alliances,%starmap,%player,%playerid);
my (@elements);
sub starmap { my($x,$y,$level,$id,$name)=@_;
	$starmap{$id}={"x"=>$x, "y"=>$y, "level"=>$level, "name"=>$name};
	$starmap{"\L$name"}=$id;
	$starmap{"$x,$y"}=$id;
}
sub alliances {
	my %h=();
	my $id;
	splice(@elements,5,1);
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "tag") {$alliances{"\L$_[$i]"}=$id}
	}
	$alliances{$id}=\%h;
}
sub player { #rank points id science culture level home_id logins from joined alliance name
	my %h=();
	my $id;
	splice(@_,7,1);
	for(my $i=0; $i<=$#elements; ++$i) {
		if($elements[$i] eq "id") {$id=$_[$i]}
		else {$h{$elements[$i]}=$_[$i];}
		if($elements[$i] eq "name") {$playerid{$_[$i]}=$id}
	}
	$player{$id}=\%h;
}

for my $f (@::files) {
#for my $f (qw(alliances starmap player)) {
	my $file="$f.csv";
	my $head=1;
	open(F, $file) or die "could not open $file: $!";
	while(<F>) {
		chomp();
		my @a=split ("\t", $_);
		if($head) {
			@elements=@a;
			$head=0;
			next;
		}
		#print "$f $_\n";
		&$f(@a);
	}
}
#my $x=$starmap{$starmap{"0,0"}};
#my $x=$alliances{$alliances{"TGD"}};
#my $x=$player{49545};
#foreach(keys(%$x)) {
#	print "$_ = $$x{$_}\n";
#}
#print $playerid{"greenbird"},"\n";

1;
