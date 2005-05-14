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
#if($ENV{REMOTE_USER} ne "guest") {
	tie(%relation, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm", O_RDONLY);# or print $head,"\nerror accessing DB\n";
	tie(%planetinfo, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm", O_RDONLY);# or print $head,"\nerror accessing DB\n";
#}

sub getrelation($) { my($name)=@_;
	my $rel=$::relation{"\L$name"};
	my ($effrel,$ally,$info,$realrel);
	if(!$rel || $rel=~/^0 /) {
#		if(!$rel) { return undef; }
		my $id=playername2id($name);
		if(!$id) { return undef }
		my $aid=$::player{$id}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel && $rel=~/^\d+ (\w+) (.*)/s) {$atag=$1;$aid=-1; $info=$2}
		if(!$aid) { return undef }
		if(!$atag) {$atag=$::alliances{$aid}{tag};}
#		print "id $id a $aid at $atag\n<br>";
		if($rel && $rel=~/^(\d+) (\w+) (.*)/s) {$info=$3}
		$rel=$::relation{"\L$atag"};
		if(!$rel) { return undef }
		$rel=~/^(\d+) (\w+) /s;
		return ($1,$2,$info,0);
	}
	$rel=~/^(\d+) (\w+) (.*)/s;
	($effrel,$ally,$info)=($1, $2, $3);
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel);
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
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$::planets{$sid};
	if(!$sys) {return undef}
	$$sys[$pid-1];
}
sub getplanetinfo($$) { my($sid,$pid)=@_;
	my $pinfo=$::planetinfo{"$sid#$pid"};
	if(!$pinfo){return ()}
	$pinfo=~/^(\d) (\d+) (.*)/s;
	return ($1,$2,$3);
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
sub systemid2coord($) { my($id)=@_;
	$::starmap{$id}?($::starmap{$id}{x},$::starmap{$id}{y}):undef;
}
sub allianceid2tag($) { my($id)=@_;
	$::alliances{$id}?$::alliances{$id}{tag}:undef;
}
sub alliancetag2id($) { my($tag)=@_;
        $::alliances{"\L$tag"}	#?$::alliances{$id}{tag}:undef;
}
sub playerid2alliance($) { my($id)=@_;
	$::player{$id}?$::player{$id}{alliance}:undef;
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
sub getatag($) {my($tag)=@_;
	if(!$tag) { return ""; }
	return "[$tag]";
}
sub sidpid2planet($) {my ($sidpid)=@_;
	my @p=split('#',$sidpid);
	return getplanet($p[0],$p[1])#$::planets{$p[0]}[$p[1]-1];
}

1;
