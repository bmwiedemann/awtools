use strict;
use Time::Local;

our $server="www1.astrowars.com";
our $bmwserver="aw.lsmod.de";
our @month=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our @weekday=qw(Sun Mon Tue Wed Thu Fri Sat);
our %relationname=(0=>"from alliance", 1=>"total war", 2=>"foe", 3=>"tense", 4=>"unknown(neutral)", 5=>"implicit neutral", 6=>"NAP", 7=>"friend", 8=>"ally", 9=>"member");
our %planetstatusstring=(1=>"unknown", 2=>"planned by", 3=>"targeted by", 4=>"sieged by", 5=>"taken by", 6=>"lost to", 7=>"defended by");
our @sciencestr=qw(Biology Economy Energy Mathematics Physics Social);
our @racestr=qw(growth science culture production speed attack defense);
our @racebonus=qw(0.09 0.10 0.04 0.04 0.19 0.15 0.15);
our $magicstring="automagic:";
our %artifact=("BM"=>4, "AL"=>2, "CP"=>1, "CR"=>5, "CD"=>8, "MJ"=>10, "HOR"=>15);




sub AWheader2($) { my($title)=@_;
	start_html($title). a({href=>"index.html"}, "AW tools index"). h1($title);
}
sub AWheader($) { my($title)=@_; header().AWheader2($title);}

sub mon2id($) {my($m)=@_;
        for(my $i=0; $i<12; $i++) {
                if($m eq $month[$i]) {return $i}
        }
}

sub parseawdate($) {my($d)=@_;
        return undef if($d!~/(\d\d):(\d\d):(\d\d)\s-\s(\w{3})\s(\d+)/);
        return timegm($3,$2,$1,$5, mon2id($4), (gmtime())[5]);
}

sub getrelationcolor($) { my($rel)=@_;
        if(!$rel) { $rel=4; }
        ("", "Firebrick", "OrangeRed", "orange", "grey", "navy", "RoyalBlue", "Turquoise", "lightgreen", "green")[$rel];
}

sub getstatuscolor($) { my($s)=@_; if(!$s) {$s=1}
        (qw(black black blue cyan red green orange green))[$s];
}
# http://www.iconbazaar.com/color_tables/lepihce.html

sub planetlink($) {my ($id)=@_;
        my $escaped=$id;
        $escaped=~s/#/%23/;
        return qq!<a href="planet-info?id=$escaped">$id</a>!;
}
sub profilelink($) { my($id)=@_;
        qq!<a href="http://$::server/about/playerprofile.php?id=$id"><img src="/images/aw/profile1.gif" title="public"></a> <a href="http://$::server/0/Player/Profile.php/?id=$id"><img src="/images/aw/profile2.gif"></a>\n!;
}
sub alliancedetailslink($) { my($id)=@_;
        qq!<a href="http://$::server/0/Alliance/Detail.php/?id=$id"><img src="/images/aw/profile3.gif"></a>\n!;
}
sub systemlink($) { my($id)=@_;
        qq!<a href="system-info?id=$id">info for system $id</a>\n!;
}


sub addplayerir($@@;$@@) { my($oldentry,$sci,$race,$newlogin,$trade,$prod)=@_;
	foreach($race,$sci,$trade) {next unless defined $_; if(!@$_){$_=undef}}
	if($race) {$race="race:".join(",",@$race);} else {undef $race}
	if($sci) {$sci="science:".time().",".join(",",@$sci);} else {undef $sci}
	if($trade) {$trade="trade:".join(",",@$trade);} else {undef $trade}
	if($prod) {$prod="production:".join(",",@$prod);} else {undef $prod}
	if(!$oldentry) {$oldentry="0 UNKNOWN "}
	my ($rest,$magic)=($oldentry,$magicstring." ");
	if($oldentry=~/^(\d+ \w+ .*)(?=$magicstring)(.*)/s){
		($rest,$magic)=($1,$2);
	}
#	if(!$magic) {$magic=$magicstring." "}
	if($trade && $magic!~s/trade:\S*/$trade/) {$magic=~s/automagic:/$&\n$trade /}
	if($prod && $magic!~s/productio:\S*/$prod/) {$magic=~s/automagic:/$&\n$prod /}
	if($sci && $magic!~s/science:[-+,.0-9]*/$sci/) {$magic=~s/automagic:/$&\n$sci /}
	if($race && $magic!~s/race:[-+,0-9]*/$race/) {$magic=~s/automagic:/$&\n$race /}
	if($newlogin) {
		my @l2;
		@l2=($newlogin=~/(\d+):(\d+)\+(\d+)/);
		my $add=1;
		if($oldentry=~/$l2[0]:(\d+)\+(\d+)/) {
			my $diff=abs($l2[1]-$1);
			#print "debug: $1 + $2 @l2 diff $diff";
			if($diff<$l2[2]) { $add=0; }
		}
		$magic.=" login:".$newlogin if $add;
	}
	chomp($rest);
	return $rest."\n".$magic;
}

sub fleet2cv(@) { my($fleet)=@_;
	return $$fleet[2]*3+$$fleet[3]*24+$$fleet[4]*60;
}
sub addfleet($$$$$@) { my($oldentry,$pid, $name, $time, $own, $fleet)=@_;
	my $status=4;
	my $ships=0;
	if($own) {$status=7}
	if($own==0) {$status=4}
	if($time) {$status=3; $time-=3600*$::options{tz}}
	else {$time=time()}
	my $gmtime=gmtime($time);
	for my $s (@$fleet) {$ships+=$s}
	my $CV=fleet2cv($fleet);
	#if($CV<10) {return $oldentry}
	if($ships<4 && $status!=4) {return $oldentry}
	$oldentry||="$status $pid";
	if($oldentry=~/@$fleet/ || $time<time()-3600*24) {return $oldentry}
	return "$oldentry \nautomagic:$name:$gmtime @$fleet ${CV}CV";
}


sub relation2race($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/race:([0-9,+-]*)/);
	return split(",", $1);
}
sub relation2science($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/science:([0-9,.+-]*)/);
	return split(",", $1);
}
sub relation2production($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/production:(\S*)/);
	my @prod=split(",", $1);
	my @race=relation2race($_[0]);
	return undef unless @race;
	for(my $i=0; $i<@race; ++$i){$race[$i]=$race[$i]*$racebonus[$i]}
	my $a=$prod[3];
	my $t=1+$prod[4]*0.01;
	my @bonus=($t,$t,$t,$t);
	if($a=~/(\w+)(\d)/) {
		my $effect=$artifact{$1};
		for(my $i=0; $i<@race; ++$i) {
			if((1<<$i) & $effect)
			{$race[$i]+=0.1*$2}
		}
	}
	$bonus[0]+=$race[3]; # prod
	$bonus[1]+=$race[1]; # sci
	$bonus[2]+=$race[2]; # cul
	$bonus[3]+=$race[0]; # grow
	push(@prod, @bonus);
#	for(my $i=0; $i<3; ++$i){ $prod[$i]+=$bonus[$i]; }
	return @prod;
}

sub gmdate($) {
	my @a=gmtime($_[0]); $a[5]+=1900;
	return "$month[$a[4]] $a[3] $a[5]";
}

1;
