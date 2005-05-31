#!/usr/bin/perl -w

#use MLDBM qw(DB_File Storable);
use DBI;
use Tie::DBI;
use DB_File;
#use Fcntl;
use strict "vars";
require "standard.pm";
require "dbconf.pm";
my $head="Content-type: text/plain\015\012";
our (%planets,%alliances,%starmap,%player,%playerid,%relation,%planetinfo);
(undef,undef,undef)=($::connectionInfo,$::dbuser,$::dbpasswd); #dummy
my $dbh = DBI->connect($::connectionInfo,$::dbuser,$::dbpasswd);
if(!$dbh) {die "DB err: $!"}
tie %planets,'Tie::DBI',$dbh,'planets','sidpid',{CLOBBER=>1};
tie %player,'Tie::DBI',$dbh,'player','pid',{CLOBBER=>1};
tie %playerid,'Tie::DBI',$dbh,'player','name',{CLOBBER=>1};
tie %alliances,'Tie::DBI',$dbh,'alliances','aid',{CLOBBER=>1};
tie %starmap,'Tie::DBI',$dbh,'starmap','sid',{CLOBBER=>1};
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
		my $rel2=$::relation{"\L$atag"};
		if($rel2) { 
			$rel2=~/^(\d+) (\w+) /s;
			return ($1,$2,$info,0);
		}
		if(!$rel) { return undef }
	}
	$rel=~/^(\d+) (\w+) (.*)/s;
	($effrel,$ally,$info)=($1, $2, $3);
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel);
}

sub playername2id($) { my($name)=@_;
#	print qq!$name = $::playerid{"\L$name"}\n!;
	$::playerid{"\L$name"}{pid};
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
	$::player{$id}{country};
}
sub getplanet2($) { $::planets{$_[0]} }
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$::planets{$sid*12+$pid-1};
}
sub getplanetinfo($$) { my($sid,$pid)=@_;
	my $pinfo=$::planetinfo{"$sid#$pid"};
	if(!$pinfo){return ()}
	$pinfo=~/^(\d) (\d+) (.*)/s;
	return ($1,$2,$3);
}
sub systemname2id($) { my($name)=@_;
	$name=~s/\s+/ /;
	my %starmapbyname;
	tie %starmapbyname,'Tie::DBI',$dbh,'starmap','name',{};
	$starmapbyname{$name}{sid};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	my $sid;
	my $query = "SELECT sid from starmap where x=$x and y=$y";
	my $sth = $dbh->prepare($query);
	if(!$sth->execute()) {return undef}
	$sth->bind_columns(\$sid);
	$sth->fetch();
	$sth->finish();
	$sid;
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
	my @p;
	for(my $i=$id*12; $i<($id+1)*12; ++$i) {
		my $x=$::planets{$i};
		if($x){push @p,$x}
	}
	@p;
}
sub allianceid2tag($) { my($id)=@_;
	$::alliances{$id}?$::alliances{$id}{tag}:undef;
}
sub allianceid2members($) { my($id)=@_;
	my %playerbyaid;
	tie %playerbyaid,'Tie::DBI',$dbh,'player','alliance',{};
        @{$playerbyaid{$id}{pid}};
}
sub alliancetag2id($) { my($tag)=@_;
	my %alliancesbytag;
	tie %alliancesbytag,'Tie::DBI',$dbh,'alliances','tag',{};
        $alliancesbytag{"\L$tag"}{aid};
}
sub playerid2alliance($) { my($id)=@_;
	$::player{$id}?$::player{$id}{alliance}:undef;
}
sub playerid2planets($) { my($id)=@_;
	my %planetsbyowner;
	tie %planetsbyowner,'Tie::DBI',$dbh,'planets','ownerid',{};
        @{$planetsbyowner{$id}{sidpid}};
}
sub playerid2tag($) { my($id)=@_;
	allianceid2tag(playerid2alliance($id));
}
sub planet2sb($) { my($h)=@_;
        $h?$$h{starbase}:undef;
}
sub planet2pop($) { my($h)=@_;
        $h?$$h{population}:undef;
}
sub planet2opop($) { my($h)=@_;
        $h?$$h{opop}:undef;
}
sub planet2siege($) {my($h)=@_;
	$h?$$h{siege}:undef;
}
sub planet2sid($) {my($h)=@_;
	$h?int(($$h{sidpid})/12):undef;
}
sub planet2pid($) {my($h)=@_;
	$h?(($$h{sidpid})%12+1):undef;
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
