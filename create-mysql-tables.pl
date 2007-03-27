#!/usr/bin/perl
use strict;
use warnings;
use DBAccess;
if(!$dbh) {die "DB err: $!"}

# create tables
$dbh->do(qq!
CREATE TABLE `cdlive` (
`pid` INT NOT NULL ,
`time` INT,
`points` INT,
`pl` INT,
PRIMARY KEY ( `pid` )
);!);

$dbh->do(qq!
CREATE TABLE `readaccess` (
`tag` VARCHAR(5) NOT NULL,
`readertag` VARCHAR(5) NOT NULL,
UNIQUE ( `tag`,readertag )
);!);

$dbh->do(qq!
CREATE TABLE `imessage` (
`imid`   INT AUTO_INCREMENT PRIMARY KEY,
`time` INT NOT NULL,
`sendpid` INT NOT NULL,
`recvpid` INT NOT NULL,
`msg` TEXT NOT NULL,
INDEX ( `time` ),
INDEX ( `recvpid` )
);!);

$dbh->do(qq!
CREATE TABLE `plhistory` (
`time` INT NOT NULL,
`pid` INT NOT NULL,
`pl` VARCHAR(6) NOT NULL,
`alli` VARCHAR(7) NOT NULL,
INDEX ( `time` ),
UNIQUE ( pid,alli,pl )
);!);

$dbh->do(qq!
CREATE TABLE `battles` (
`id` INT NOT NULL,
`cv_def` INT,
`cv_att` INT,
`att_id` INT,
`def_id` INT,
`win_id` INT,
`planet_id` TINYINT,
`system_id` INT,
`time` INT NOT NULL,
PRIMARY KEY ( `id` )
);!);

$dbh->do(qq!
CREATE TABLE `ipban` (
`ip` VARCHAR(16) NOT NULL,
`timeadded` INT NOT NULL,
`reason` VARCHAR(255) NOT NULL,
PRIMARY KEY ( `ip` )
);!);

$dbh->do(qq!
CREATE TABLE `alltrades` (
`tid` INT NOT NULL,
`pid1` INT NOT NULL,
`pid2` INT NOT NULL,
`time` INT,
PRIMARY KEY ( `tid` ),
UNIQUE ( `pid1`,pid2 ),
INDEX (`pid2`)
);!);

$dbh->do(qq!
CREATE TABLE `trades` (
`pid1` INT NOT NULL,
`pid2` INT NOT NULL,
`time` INT,
UNIQUE ( `pid1`,pid2 ),
INDEX (`pid2`)
);!);

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
pid  MEDIUMINT NOT NULL,
name VARCHAR ( 64 ) NOT NULL,
nclick INT ,
firstclick INT NOT NULL ,
lastclick INT NOT NULL ,
ip VARCHAR ( 15 ) NOT NULL,
auth TINYINT ( 1 ) NOT NULL,
PRIMARY KEY ( sessionid ),
KEY ( name ),
KEY ( lastclick )
);!);

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
name VARCHAR ( 24 ) NOT NULL ,
UNIQUE ( name ),
INDEX ( alliance ),
PRIMARY KEY ( pid ));!);

$dbh->do(qq!
CREATE TABLE playerprefs (
pid MEDIUMINT UNSIGNED NOT NULL ,
tz  MEDIUMINT,
customhtml TEXT,
storeir    BOOL,
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
`trn` MEDIUMINT (5) ,
`cls` MEDIUMINT (5) ,
`ds` MEDIUMINT (5) ,
`cs` MEDIUMINT (5) ,
`bs` MEDIUMINT (5) ,
`cv` INT( 6 ) NOT NULL ,
`xcv` INT( 6 ) NOT NULL ,
 iscurrent TINYINT(1) NOT NULL,
`info` VARCHAR( 200 ) NULL ,
INDEX ( alli ),
INDEX (`status`),
INDEX (`owner`),
INDEX ( sidpid ),
INDEX ( eta ),
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
print "done\n";
1;
