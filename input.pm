#!/usr/bin/perl -w

use MLDBM qw(DB_File Storable);
use DB_File;
use Fcntl;
use strict "vars";
require "standard.pm";
my $head="Content-type: text/plain\015\012";
our (%alliances,%starmap,%player,%playerid,%planets,%relation,%planetinfo);
tie %alliances, "MLDBM", "db/alliances.mldbm", O_RDONLY, 0666 or die $!;
tie %starmap, "MLDBM", "db/starmap.mldbm", O_RDONLY, 0666;
tie %player, "MLDBM", "db/player.mldbm", O_RDONLY, 0666;
tie %playerid, "MLDBM", "db/playerid.mldbm", O_RDONLY, 0666;
tie %planets, "MLDBM", "db/planets.mldbm", O_RDONLY, 0666;
my $dbnamer="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
my $dbnamep="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
#if($ENV{REMOTE_USER} ne "guest") {
	tie(%relation, "DB_File", $dbnamer, O_RDONLY);# or print $head,"\nerror accessing DB\n";
	tie(%planetinfo, "DB_File", $dbnamep, O_RDONLY);# or print $head,"\nerror accessing DB\n";
#}

sub getrelation($;$) { my($name)=@_;
	my $lname="\L$name";
	my $rel=$::relation{$lname};
	my ($effrel,$ally,$info,$realrel,$hadentry);
	my $hadentry=0;
	if($rel && $rel=~/^(\d+) (\w+) (.*)/s) {
		($effrel,$ally,$info)=($1, $2, $3);
		$hadentry=1
	}
	while(!$rel || !$effrel) {
#		if(!$rel) { return undef; }
		my $id=playername2id($name);
		if(!$id) {
			if($hadentry){last}
			return undef
		}
		my $aid=$::player{$id}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel) {$atag=$ally;$aid=-1;}
		if(!$aid) { return undef }
		if($aid>0) {$ally=$atag=$::alliances{$aid}{tag};}
#		print "id $id a $aid at $atag\n<br>";
		my $rel2=$::relation{"\L$atag"};
		if($rel2) { 
			$rel2=~/^(\d+) (\w+) /s;
			return ($1,$2,$info,0,$hadentry,$lname);
		}
		if(!$rel) { return undef }
		last;
	}
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel,1,$lname);
}
sub setrelation($%) { my($id,$options)=@_;
	my %data;
	tie(%data, "DB_File", $dbnamer);
	if(!$id) {$id=$$options{name}}
	#print "set '$id', '$options' $dbnamer ";
	if(!$options) {delete $data{$id}; }
	else {
		$data{$id}="$$options{status} $$options{atag} $$options{info}";
	}
	untie(%data);
}

sub playername2id($) { my($name)=@_;
#	print qq!$name = $::playerid{"\L$name"}\n!;
	$::playerid{"\L$name"};
}
sub playerid2name($) { my($id)=@_;
	if(!defined($id)) {return "unknown"}
	if($id<=2 || !$::player{$id}) {return "unknown"}
	$::player{$id}{name};
}
sub playerid2home($) { my($id)=@_;
	if(!defined($id)) {return undef}
	if($id<=2 || !$::player{$id}) {return undef}
	$::player{$id}{home_id};
}
sub playerid2country($) { my($id)=@_;
	$::player{$id}{from};
}
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$::planets{$sid};
	if(!$sys) {return undef}
	$$sys[$pid-1];
}
sub getplanetinfo($$;$) { my($sid,$pid)=@_;
	my $id="$sid#$pid";
	my $pinfo=$::planetinfo{$id};
	if(!$pinfo){return ()}
	$pinfo=~/^(\d) (\d+) (.*)/s;
	return ($1,$2,$3,$id);
}
sub setplanetinfo($%) { my($id,$options)=@_;
	my %data;
	tie(%data, "DB_File", $dbnamep);
	if(!$id) {$id=$$options{sidpid}}
	#print "set '$id', '$options' $dbnamep ";
	if(!$options) {delete $data{$id}; }
	else {
		$data{$id}="$$options{status} $$options{who} $$options{info}";
	}
	untie(%data);
}
sub systemname2id($) { my($name)=@_;
	$name=~s/\s+/ /;
	$::starmap{"\L$name"};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	$::starmap{"$x,$y"};
}
sub systemid2name($) { my($id)=@_;
	$::starmap{$id}?$::starmap{$id}{name}:undef;
}
sub systemid2level($) { my($id)=@_;
	$::starmap{$id}?$::starmap{$id}{level}:undef;
}
sub systemid2coord($) { my($id)=@_;
	$::starmap{$id}?($::starmap{$id}{x},$::starmap{$id}{y}):undef;
}
sub systemid2planets($) { my($id)=@_;
        $::planets{$id}?@{$::planets{$id}}:undef;
}
sub allianceid2tag($) { my($id)=@_;
	$::alliances{$id}?$::alliances{$id}{tag}:undef;
}
sub allianceid2members($) { my($id)=@_;
        $::alliances{$id}?@{$::alliances{$id}{m}}:undef;
}
sub alliancetag2id($) { my($tag)=@_;
        $::alliances{"\L$tag"}	#?$::alliances{$id}{tag}:undef;
}
sub playerid2alliance($) { my($id)=@_;
	$::player{$id}?$::player{$id}{alliance}:undef;
}
sub playerid2planets($) { my($id)=@_;
        $::player{$id}?@{$::player{$id}{planets}}:undef;
}
sub playerid2tag($) { my($id)=@_;
	allianceid2tag(playerid2alliance($id));
}
sub planet2sb($) { my($h)=@_;
        $h?$$h{sb}:undef;
}
sub planet2pop($) { my($h)=@_;
        $h?$$h{pop}:undef;
}
sub planet2opop($) { my($h)=@_;
        $h?$$h{opop}:undef;
}
sub planet2siege($) {my($h)=@_;
	$h?$$h{s}:undef;
}
sub planet2pid($) {${$_[0]}{planetid}}
sub planet2sid($) {${$_[0]}{systemid}}
sub getatag($) {my($tag)=@_;
	if(!$tag) { return ""; }
	return "[$tag]";
}
sub sidpid2planet($) {my ($sidpid)=@_;
	my @p=split('#',$sidpid);
	return getplanet($p[0],$p[1])#$::planets{$p[0]}[$p[1]-1];
}
sub getplanet2($) { sidpid2planet($_[0]) }
sub sidpid22sidpid3($$) { "$_[0]#$_[1]" }

1;
