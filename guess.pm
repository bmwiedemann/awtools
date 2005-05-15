use strict;

require "input.pm";

use Neuron;
my $debug=0;
my $nnetfile="nnet-race";

srand(124);
my $net;
my $inneurons=10;
my $outneurons=2;
my @scales=(600,4000,40,40,40,40,40,40,500,40,  8,8,8,8,8,8,8,8,8);
my @bias=  (0,  0,   0, 0, 0, 0, 0, 0, 0,  0,   4,4,4,4,4,4,4,4,4);
my $values=$inneurons+$outneurons;

sub translateback { my ($result)=@_;
	return;
	foreach(@$result) {
		$_*=8;
		$_-=4;
	}
}
sub translate { my ($e)=@_;
		for(my $i=0; $i<$values; $i++){
			$$e[$i]=($$e[$i]+$bias[$i])/$scales[$i];
		}
}


sub guessrace {my($test)=@_;
	if($debug){print "@$test";}
	translate($test);
	my @result=$net->run(@$test);
	translateback(\@result);
	if($debug){print " -> @result\n";}
	return @result;
}

sub learn {my ($data)=@_;
  my $n=6000;
  for my $j (1..$n) {
  	my $part=$j/$n;
	my $i=rand(@$data);
	my $e=$$data[$i];
#	foreach my $e (@$data) {
#		print "@$e\n";
		translate($e);
#		print "@$e\n";
		$net->train(0.5-0.1*$part,5-1*$part,@$e);
#	}
  }
}

sub getpubdata($) {my ($pid)=@_;

	my $p=$::player{$pid};
	return undef unless $$p{planets};
	my $planets=@{$$p{planets}};
	my $highestpop=0;
	my $lowestpop=1000;
	my $totalpop=0;
	foreach(@{$$p{planets}}) {
		my $pp=sidpid2planet($_);
		my $pop=planet2pop($pp);
		$highestpop=$pop if($pop>$highestpop);
		$lowestpop=$pop if($pop<$lowestpop);
		$totalpop+=$pop;
	}
	my @pubdata=($$p{points},$$p{rank},$planets,$$p{culture},$$p{science},$$p{level},$highestpop,$lowestpop,$totalpop,$$p{points}-$totalpop-3*$$p{level});
}

my @data;
sub initguess() {
	$net=new NNet($inneurons,20,$outneurons);
	while(my @a=each %::relation) {
		my @race=relation2race($a[1]);
		next unless $race[0];
		my $pid=playername2id($a[0]);
		my @pubdata=getpubdata($pid);
		next if(!$pubdata[0]);
		if($debug){print "$a[0]:$pid:@race @pubdata\n";}
		#push(@race,($race[5]+$race[6])/2,($race[0]+$race[2])/2);
		@race=(($race[5]+$race[6])/2,($race[0]+$race[2])/2);
		push(@data, [@pubdata,@race]);
	}
	learn(\@data);
	$net->save($nnetfile);
}

sub loadnet { $net=load NNet($nnetfile); }

if(-e $nnetfile) {loadnet()}
else{ initguess() }

#runtest([qw(486 45 22 22 28 18 22 7 394 38)]);
#runtest([qw(382 451 15 17 25 40 18 9 247 15)]);
for my $pid (qw(49545 24014 19832 56530 48306 16242)) {
	printf ("$pid race fighter%.4f ranker%.4f\n",guessrace([getpubdata($pid)]));
}

1; 
