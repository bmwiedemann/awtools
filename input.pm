#!/usr/bin/perl -w

use MLDBM qw(DB_File Storable);
use DB_File;
use Fcntl;
use strict "vars";
require "standard.pm";
our (%alliances,%starmap,%player,%playerid,%planets,%relation,%planetinfo);
tie %alliances, "MLDBM", "db/alliances.mldbm", O_RDONLY, 0666 or die $!;
tie %starmap, "MLDBM", "db/starmap.mldbm", O_RDONLY, 0666;
tie %player, "MLDBM", "db/player.mldbm", O_RDONLY, 0666;
tie %playerid, "MLDBM", "db/playerid.mldbm", O_RDONLY, 0666;
tie %planets, "MLDBM", "db/planets.mldbm", O_RDONLY, 0666;
if($ENV{REMOTE_USER} ne "guest") {
	tie(%relation, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm", O_RDONLY) or print "error accessing DB\n";
	tie(%planetinfo, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm", O_RDONLY) or print "error accessing DB\n";
}

sub getrelation($) { my($name)=@_;
	my $rel=$::relation{"\L$name"};
	if(!$rel) {
#		if(!$rel) { return undef; }
		my $id=$::playerid{"\L$name"};
		if(!$id) { return undef }
		my $aid=$::player{$id}{alliance};
#		print "aid $aid \n";
		if(!$aid) { return undef }
		my $atag=$::alliances{$aid}{tag};
#		print "id $id a $aid at $atag\n<br>";
		$rel=$::relation{"\L$atag"};
		if(!$rel) { return undef }
	}
	$rel=~/^(\d+) (\w+) (.*)/s;
	return ($1, $2, $3);
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
	$::starmap{"\L$name"};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	$::starmap{"$x,$y"};
}
sub systemid2name($) { my($id)=@_;
	$::starmap{$id}?$::starmap{$id}{name}:undef;
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
sub planet2siege($) {my($h)=@_;
	$h?$$h{s}:undef;
}
sub getatag($) {my($tag)=@_;
	if(!$tag) { return ""; }
	return "[$tag]";
}

1;
