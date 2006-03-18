#!/usr/bin/perl -w

use DBI;
use MLDBM qw(DB_File Storable);
use Fcntl;
use strict;
use DBAccess;
# make connection to database
#my $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}

if(0) { # create tables
$dbh->do(qq!
CREATE TABLE `cdcv` (
`sidpid` INT NOT NULL ,
`time` INT,
`cv` INT,
PRIMARY KEY ( `sidpid` )
);!);

$dbh->do(qq!
CREATE TABLE usersession (
sessionid CHAR ( 32 ) BINARY NOT NULL ,
name VARCHAR ( 64 ) NOT NULL,
nclick INT ,
firstclick INT NOT NULL ,
lastclick INT NOT NULL ,
ip VARCHAR ( 15 ) NOT NULL,
auth TINYINT ( 1 ) NOT NULL,
PRIMARY KEY ( sessionid ),
KEY `lastclick` ( lastclick )
) TYPE=MEMORY;!);
#exit 0;

$dbh->do(qq!
CREATE TABLE starmap (
sid SMALLINT( 16 ) UNSIGNED NOT NULL ,
x SMALLINT( 16 ) NOT NULL ,
y SMALLINT( 16 ) NOT NULL ,
level TINYINT( 8 ) NOT NULL ,
name VARCHAR( 40 ) NOT NULL ,
UNIQUE ( x,y ),
INDEX ( name ),
PRIMARY KEY ( sid ));!);

$dbh->do(qq!
CREATE TABLE alliances (
aid INT( 16 ) UNSIGNED NOT NULL ,
tag VARCHAR ( 5 ) NOT NULL ,
founder INT( 24 ) NOT NULL ,
daysleft INT( 8 ) NOT NULL ,
members INT( 16 ) NOT NULL ,
points INT( 16 ) NOT NULL ,
permanent SMALLINT ( 6 ) NOT NULL ,
name VARCHAR( 50 ) NOT NULL ,
url VARCHAR( 50 ) NULL ,
UNIQUE ( tag ),
PRIMARY KEY ( aid ));!);
$dbh->do(qq!
CREATE TABLE player (
pid MEDIUMINT UNSIGNED NOT NULL ,
points SMALLINT NOT NULL ,
rank MEDIUMINT( 16 ) NOT NULL ,
science TINYINT( 8 ) NOT NULL ,
culture TINYINT( 8 ) NOT NULL ,
level TINYINT( 8 ) NOT NULL ,
home_id SMALLINT( 16 ) NOT NULL ,
logins MEDIUMINT( 16 ) NOT NULL ,
trade SMALLINT( 6 ) NOT NULL ,
country VARCHAR ( 3 ) NOT NULL ,
joined INT( 15 ) NOT NULL ,
alliance SMALLINT( 16 ) NOT NULL ,
name VARCHAR ( 50 ) NOT NULL ,
UNIQUE ( name ),
INDEX ( alliance ),
PRIMARY KEY ( pid ));!);
$dbh->do(qq!
CREATE TABLE planets (
sidpid MEDIUMINT( 6 ) UNSIGNED NOT NULL ,
population TINYINT( 2 ) NOT NULL ,
opop TINYINT( 2 ) NOT NULL ,
starbase TINYINT( 2 ) NOT NULL ,
ownerid MEDIUMINT( 7 ) NOT NULL ,
siege ENUM ( '0', '1' ) NOT NULL ,
INDEX ( ownerid ),
PRIMARY KEY ( sidpid ));!);
$dbh->do(qq!
CREATE TABLE `planetinfos` (
`id` INT ( 14 ) NOT NULL AUTO_INCREMENT,
`alli` VARCHAR( 7 ) NOT NULL ,
`sidpid` INT( 16 ) UNSIGNED NOT NULL ,
`status` INT( 2 ) UNSIGNED NOT NULL ,
`who` INT( 16 ) UNSIGNED NOT NULL ,
`time` INT( 16 ) NULL ,
`added` INT( 16 ) NOT NULL ,
`info` TEXT NULL ,
INDEX ( who ),
UNIQUE ( `sidpid`, `alli` ),
PRIMARY KEY ( id )
);!);
$dbh->do(qq!
CREATE TABLE `relations` (
`id` INT ( 14 ) NOT NULL AUTO_INCREMENT,
`alli` VARCHAR( 7 ) NOT NULL ,
`name` VARCHAR( 30 ) NOT NULL ,
`status` INT( 4 ) UNSIGNED DEFAULT '4' NOT NULL ,
`atag` VARCHAR( 8 ) NULL ,
`race` VARCHAR( 30 ) NULL ,
`science` VARCHAR( 30 ) NULL ,
`sciencedate` INT (15) NULL,
`info` TEXT NULL ,
INDEX ( alli ),
INDEX ( status ),
UNIQUE ( `name`,`alli` ),
PRIMARY KEY ( id )
);!);
$dbh->do(qq!  
CREATE TABLE `logins` (
`lid` INT ( 14 ) NOT NULL AUTO_INCREMENT,
`alli` VARCHAR( 7 ) NOT NULL ,
`pid` INT ( 8 ) NOT NULL ,
`n` INT ( 4 ) ,
`time` INT ( 15 ),
`idle` INT ( 6 ),
`fuzz` INT ( 8 ),
INDEX ( `alli` ),
INDEX ( `pid`,`n` ),
PRIMARY KEY ( `lid` )
);!);
$dbh->do(qq!
CREATE TABLE `fleets` (
`fid` INT ( 14 ) NOT NULL AUTO_INCREMENT,
`alli` VARCHAR( 7 ) NOT NULL ,
`status` INT( 2 ) UNSIGNED DEFAULT '0' NOT NULL ,
`sidpid` INT( 16 ) UNSIGNED NOT NULL ,
`owner` INT( 16 ) UNSIGNED NOT NULL ,
`eta` INT( 16 ) NULL ,
`firstseen` INT( 16 ) NOT NULL ,
`lastseen` INT( 16 ) NOT NULL ,
`trn` SMALLINT (5) ,
`cls` SMALLINT (5) ,
`ds` SMALLINT (5) ,
`cs` SMALLINT (5) ,
`bs` SMALLINT (5) ,
`cv` INT( 6 ) NOT NULL ,
`xcv` INT( 6 ) NOT NULL ,
 iscurrent TINYINT(1) NOT NULL,
`info` VARCHAR( 200 ) NULL ,
INDEX ( alli ),
INDEX (`status`),
INDEX (`owner`),
PRIMARY KEY ( `fid` )
);!);
#$dbh->do(qq!
#CREATE TABLE `transfers` (
#`tid` INT ( 14 ) NOT NULL AUTO_INCREMENT,
#`alli` VARCHAR( 7 ) NOT NULL,
#`time` INT ( 16 ) NOT NULL,
#`splayer` INT ( 16 ) NOT NULL,
#`dplayer` INT ( 16 ) NOT NULL,
#`amount` SMALLINT ( 10 ) NOT NULL,
#`fees` SMALLINT ( 10 ) NOT NULL,
#UNIQUE `uniq` ( `time` , `dplayer` , `splayer` , `alli` ),
#PRIMARY KEY ( `tid` )
#);!);
exit 0;
}

our (%alliances,%starmap,%player,%playerid,%planets);
#tie %alliances, "MLDBM", "newdb/alliances.mldbm", O_RDWR|O_CREAT, 0666 or die $!;
#tie %starmap, "MLDBM", "newdb/starmap.mldbm", O_RDWR|O_CREAT, 0666;
#tie %player, "MLDBM", "newdb/player.mldbm", O_RDWR|O_CREAT, 0666;
#tie %playerid, "MLDBM", "newdb/playerid.mldbm", O_RDWR|O_CREAT, 0666;
#tie %planets, "MLDBM", "newdb/planets.mldbm", O_RDWR|O_CREAT, 0666;
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
	if(!$name) {print "$x $y\n"; $name="undefined"}
	$name=~s/\s+/ /;
	my %h=("x"=>$x, "y"=>$y, "level"=>$level, "name"=>$name, "origin" => \@{$origin[$id]});
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
		if($elements[$i] eq "ownerid") { 
			push(@{$playerplanets[$_[$i]]}, "$id#$pid");
#			push(@{$playersat[$id]}, $_[$i]) 
		}
	}
	$h{opop}=$h{population};
	my $sidpid=$id*13+$pid;
	$planets{"$sidpid"}=\%h;
#	my @temp=$planets{$id}?@{$planets{$id}}:();
#	$temp[$pid-1]=\%h;
#	$planets{$id}=\@temp;
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
}

print "pushing into MySQL DB\n";
use Tie::DBI;
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

print "done\n";
1;
