#!/usr/bin/perl -w

#use MLDBM qw(DB_File Storable);
use DBI;
use Tie::DBI;
use strict "vars";
use DBConf;
require "standard.pm";
require "access.pm";
my $head="Content-type: text/plain\015\012";
our (%planets,%alliances,%starmap,%player,%playerid,$dbh,$readalli);
$dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}
tie %planets,'Tie::DBI',$dbh,'planets','sidpid',{CLOBBER=>1};
tie %player,'Tie::DBI',$dbh,'player','pid',{CLOBBER=>0};
tie %playerid,'Tie::DBI',$dbh,'player','name',{CLOBBER=>0};
tie %alliances,'Tie::DBI',$dbh,'alliances','aid',{CLOBBER=>0};
tie %starmap,'Tie::DBI',$dbh,'starmap','sid',{CLOBBER=>0};
#tie %relation,'Tie::DBI',$dbh,'relations','id',{CLOBBER=>2};
#tie %planetinfo,'Tie::DBI',$dbh,'planetinfos','id',{CLOBBER=>2};
#tie %logins,'Tie::DBI',$dbh,'logins','lid',{CLOBBER=>2};
#tie %fleets,'Tie::DBI',$dbh,'fleets','fid',{CLOBBER=>2};
$readalli=$ENV{REMOTE_USER};

sub filterpersonal($) { my($ref)=@_;
	my %read=($ENV{REMOTE_USER}=>1);
	for(@{$::read_access{$ENV{REMOTE_USER}}}) {
		$read{$_}=1;
	}
	my @result;
	for(@$ref) {
		if($read{$$_[1]}) {
			push(@result, $_);
		}
	}
	return \@result;
}
sub selectpersonal($$) { my($ref,$wantwrite)=@_;
	my %havealli;
	my $n=0;
	for(@$ref) {
		$havealli{$$_[1]}=++$n;
	}
	if($wantwrite) {
		my $n=$havealli{$ENV{REMOTE_USER}};
		if($n) {return $$ref[$n-1];}
		else {return undef}
	}
	if($havealli{$readalli}) {return $$ref[$havealli{$readalli}-1]}
	# next select readable friends
	for my $readalli (@{$::read_access{$ENV{REMOTE_USER}}}) {
		if($havealli{$readalli}) {return $$ref[$havealli{$readalli}-1]}
	}
	return undef;
}

sub getpurerelation($$) { my($name,$wantwrite)=@_;
	my $rel=$dbh->selectall_arrayref("SELECT * FROM `relations` WHERE `name` = ".$dbh->quote("\L$name"));
	#my $rel=$::relation{"\L$name"};
	my $relarray=selectpersonal($rel,$wantwrite);
	if(!$relarray){return undef}
	@_=@$relarray;
	$rel={"id",shift,"alli",shift,"name",shift,"status",shift,"atag",shift,"race",shift,"science",shift,"sciencedate",shift,"info",shift};
}

sub getrelation($;$) { my($name,$wantwrite)=@_;
	my $rel=getpurerelation($name,$wantwrite);
	my ($effrel,$ally,$info,$realrel,$hadentry);
	if(!$rel || $$rel{status}==0) {
#		if(!$rel) { return undef; }
		my $id=playername2id($name);
		if(!$id) { return undef }
		my $aid=$::player{$id}{alliance};
		my $atag;
		if(!$aid && $rel) {$atag=$$rel{atag};$aid=-1; $info=$$rel{info}; $hadentry=1}
		if(!$aid) { return undef }
		if(!$atag) {$atag=$::alliances{$aid}{tag};}
		if($rel) {$info=$$rel{info}}
		my $rel2=getpurerelation($atag,$wantwrite);
		if($rel2) { 
			return ($$rel2{status},$$rel2{atag},$info,0,$hadentry,$rel?$$rel{id}:'');
		}
		if(!$rel) { return (4,$atag,"",0,0) }
	}
	($effrel,$ally,$info)=($$rel{status},$$rel{atag},$$rel{info});
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel,1,$$rel{id});
}
sub setrelation($%) { my($id,$options)=@_;
	my %relation;
	tie %relation,'Tie::DBI',$dbh,'relations','id',{CLOBBER=>2};
	if(!$options) {
		delete $relation{$id};
	} else {
		$$options{alli}=$ENV{REMOTE_USER};
		#print "$id $relation{$id}=";
		#foreach(keys %$options) { print "$_=$$options{$_}<br />\n"; }
		$relation{$id}=$options;
	}
#	$dbh->do("UPDATE `relations` SET `status` = ".$$options{status}.", `atag` = ".$dbh->quote($$options{atag}).", `info` = ".$dbh->quote($$options{info})." WHERE `name` = ".$dbh->quote($id)." AND `alli` = '$ENV{REMOTE_USER}' LIMIT 1 ;");
}

sub playername2id($) { my($name)=@_;
   $name="\L$name";
	$::playerid{$name}?$::playerid{$name}{pid}:undef;
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
	my $sys=$::planets{sidpid22sidpid3($sid,$pid)};
}
sub getplanetinfo($$;$) { my($sid,$pid,$wantwrite)=@_;
	my $sidpid=sidpid22sidpid3($sid,$pid);
	my $pinfo=$dbh->selectall_arrayref("SELECT * FROM `planetinfos` WHERE `sidpid` = $sidpid");
	
	#$::planetinfo{$sidpid};
	my $array=selectpersonal($pinfo,$wantwrite);
	if(!$array){return ()}
	@_=@$array;
	$pinfo={"id",shift,"alli",shift,"sidpid",shift,"status",shift,"who",shift,"time",shift,"added",shift,"info",shift};
	return ($$pinfo{status},$$pinfo{who},$$pinfo{info},$$array[0]);
}
sub setplanetinfo($%) { my($id,$options)=@_;
	my %data;
	tie %data,'Tie::DBI',$dbh,'planetinfos','id',{CLOBBER=>2};
	if(!$options) {
		delete $data{$id};
	} else {
		$$options{alli}=$ENV{REMOTE_USER};
		#print "$id ";
		#foreach(keys %$options) { print "$_=$$options{$_}<br />\n"; }
		$data{$id}=$options;
	}
}
sub systemname2id($) { my($name)=@_;
	$name=~s/\s+/ /;
	my %starmapbyname;
	tie %starmapbyname,'Tie::DBI',$dbh,'starmap','name',{};
	$starmapbyname{$name}{sid};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	return undef unless (defined ($x) and defined ($y) and $x=~/\d/ and $y=~/\d/);
	my $sid;
	my $query = "SELECT `sid` FROM `starmap` WHERE `x` = $x AND `y` = $y";
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
	return @::planets{($id*13+1..$id*13+12)};
	my @p;
	for(my $pid=1; $pid<=12; ++$pid) {
		my $x=getplanet($id,$pid);
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
	$h?int(($$h{sidpid})/13):undef;
}
sub planet2pid($) {my($h)=@_;
	$h?(($$h{sidpid})%13):undef;
}
sub getatag($) {my($tag)=@_;
	if(!$tag) { return ""; }
	return "[$tag]";
}
sub sidpid12sidpid2($) {my @p=split('#',$_[0]); return @p;}
sub sidpid22sidpid3($$) {my @p=@_; return $p[0]*13+$p[1];}
sub sidpid2planet($) {my ($sidpid)=@_;
	my @p=split('#',$sidpid);
	return getplanet($p[0],$p[1])#$::planets{$p[0]}[$p[1]-1];
}
sub dbfleetaddinit($) { my($pid)=@_;
#tie %planetinfo,'Tie::DBI',$dbh,'planetinfos','id',{CLOBBER=>2};
}
sub dbfleetadd {

}
sub dbplayeriradd {
#tie %relation,'Tie::DBI',$dbh,'relations','id',{CLOBBER=>2};
}
sub dbtransferadd($$$$$) { my($time,$splayerid,$dplayerid,$amount,$fees)=@_;
	my $alli=$dbh->quote($ENV{REMOTE_USER});
	$dbh->do(qq!INSERT INTO `transfers` VALUES ('', $alli, $time, $splayerid, $dplayerid, $amount, $fees);!);
}


1;
