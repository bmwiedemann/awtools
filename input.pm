#!/usr/bin/perl -w

use MLDBM;
use DB_File;
use Fcntl;
use strict "vars";
our (%alliances,%starmap,%player,%playerid,%planets,%relation,%planetinfo);
tie %alliances, "MLDBM", "db/alliances.mldbm", O_RDONLY, 0666 or die $!;
tie %starmap, "MLDBM", "db/starmap.mldbm", O_RDONLY, 0666;
tie %player, "MLDBM", "db/player.mldbm", O_RDONLY, 0666;
tie %playerid, "MLDBM", "db/playerid.mldbm", O_RDONLY, 0666;
tie %planets, "MLDBM", "db/planets.mldbm", O_RDONLY, 0666;
tie(%relation, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm", O_RDONLY) or print "error accessing DB\n";
tie(%planetinfo, "DB_File", "/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm", O_RDONLY) or print "error accessing DB\n";

our %relationname=(1=>"total war", 2=>"foe", 3=>"tense", 4=>"unknown(neutral)", 5=>"implicit neutral", 6=>"NAP", 7=>"friend", 8=>"ally", 9=>"member");
our %planetstatusstring=(1=>"unknown", 2=>"planned by", 3=>"targeted by", 4=>"sieged by", 5=>"taken by", 6=>"lost to");
sub getrelationcolor($) { my($rel)=@_;
	if(!$rel) { $rel=4; }
	("", "red", "orange", "yellow", "grey", "blue", "RoyalBlue", "Turquoise", "lightgreen", "green")[$rel];
}
# http://www.iconbazaar.com/color_tables/lepihce.html

sub getstatuscolor($) { my($s)=@_; if(!$s) {$s=1}
	(qw(black black blue cyan red green orange))[$s];
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
	$rel=~/^(\d+) (\w+) (.*)/;
	return ($1, $2, $3);
}
sub profilelink($) { my($id)=@_;
	qq!<a href="http://www1.astrowars.com/about/playerprofile.php?id=$id">pubprofile</a> <a href="http://www1.astrowars.com/0/Player/Profile.php/?id=$id">yourprofile</a>\n!;
}
sub systemlink($) { my($id)=@_;
	qq!<a href="system-info?id=$id">info for system $id</a>\n!;
}
sub playername2id($) { my($name)=@_;
#	print qq!$name = $::playerid{"\L$name"}\n!;
	$::playerid{"\L$name"};
}
sub playerid2name($) { my($id)=@_;
	if($id<=2 || !$::player{$id}) {return "unknown"}
	$::player{$id}{name};
}

1;
