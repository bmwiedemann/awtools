#!/usr/bin/perl -w
package awinput;
use strict "vars";
#use warnings;
require 5.002;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
our (%alliances,%starmap,%player,%playerid,%planets,
   $dbnamer);
my $startofround=0; # ((gmtime())[7]%91) <20
our $alarmtime=99;
our $tradercost=5;

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = qw(
&awinput_init &getrelation &getallirelation &setallirelation &setrelation &playername2id &playername2idm &playerid2name &playerid2namem &playerid2home &playerid2country &getplanet &getplayer &getalliance 
&playerid2lasttag &playerid2pseudotag &playerid2link &playerid2link2 &getplanetinfom &getplanetinfo &setplanetinfo &systemname2id &systemcoord2id &systemid2name &systemid2level &systemid2coord &systemid2link &systemid2planets &allianceid2tag &allianceid2members &alliancetag2id &playerid2alliance &playerid2alliancem &playerid2planets &playerid2planetsm &playerid2tag &playerid2tagm &planet2sb &planet2pop &planet2opop &planet2owner &planet2siege &planet2pid &planet2sid &getatag &getallidetailurl &playerid2plans &showplan &getlivealliscores &settoolsaccess_rmask &settoolsaccess
&sidpid2planet &getplanet2 &sidpid22sidpid3 &sidpid32sidpid2 &sidpid22sidpid3m &sidpid32sidpid2m 
&playerid2ir &playerid2iir &playerid2etc &playerid2production &relation2production &getartifactprice &getallproductions &show_fleet &dbfleetaddinit &dbfleetadd &dbfleetaddfinish &dbplayeriradd &dblinkadd &getauthname &getusernamecookie &getuseridcookie &is_admin &is_extended &is_founder &is_startofround &predict_points
&display_pid &display_relation &display_atag &display_sid &display_sid2 &sort_pid
);


use MLDBM qw(DB_File Storable);
use CGI ":standard";
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY);
use awaccess;
use DBAccess2;
use awstandard;
use awsql;
my $head="Content-type: text/plain\015\012";

my %adminlist=(greenbird=>1, cutebird=>1);

sub get_relation_dbname($)
{ my($alli)=@_;
   my($a)=get_one_row("SELECT t1.othertag FROM `toolsaccess` as t1, `toolsaccess` as t2 WHERE t1.tag=t2.othertag AND t2.tag=t1.othertag AND t1.`tag` = ? AND t1.rbits&8 AND t2.rbits&8 ORDER BY t1.othertag DESC LIMIT 1", [$alli]);
   return $a;
}

sub awinput_init(;$) { my($nolock)=@_;
   awstandard_init();
#chdir "/home/aw/db"; # done by awstandard_init
# use absolute pathes from awstandard
   tie %alliances, "MLDBM", "$dbdir/alliances.mldbm", O_RDONLY, 0666 or die $!;
   tie %starmap, "MLDBM", "$dbdir/starmap.mldbm", O_RDONLY, 0666;
   tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDONLY, 0666;
   tie %playerid, "MLDBM", "$dbdir/playerid.mldbm", O_RDONLY, 0666;
   tie %planets, "MLDBM", "$dbdir/planets.mldbm", O_RDONLY, 0666;
   my $alli=$ENV{REMOTE_USER};
	$dbnamer="";
   if($alli) {
      my $a=$alli;
      if($alli ne "guest") {
         $a=get_relation_dbname($alli);
         if(!$a) {$a="guest"}
      }
#      if($remap_relations{$alli}) {
#         $a=$remap_relations{$alli};
#      }
      $dbnamer=$a; #"$awstandard::dbmdir/$a-relation.dbm";
#      if($remap_planning{$alli}) {
#         $alli=$remap_planning{$alli};
#      }
#      untie %relation;

#     if($ENV{REMOTE_USER} ne "guest") {
      if($nolock) {
#         tie(%relation, "DB_File", $dbnamer, O_RDONLY, 0, $DB_HASH);
      } else {
         #$SIG{"ALRM"}=sub{select STDERR; $|=1; print STDERR "alarm $alarmtime; finish\n";&awinput_finish; require POSIX; POSIX::_exit(0);};
         #alarm($alarmtime); # make sure locks are free'd
#         tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
      }
   } else {
      # make sure it isnt tied and stored
#      untie %relation;
#      %relation=();
   }
}


# release locks allocated in awinput_finish
sub awinput_finish() {
#   untie(%relation);
   alarm(0);
}

sub getauthname() { 
   return $ENV{HTTP_AWUSER}; # header set by brownie/testauth.pm
#   my $cookies=$ENV{HTTP_COOKIE};
#   my $session=awstandard::cookie2session($cookies);
#   if($session) {
#      my $ip=$ENV{REMOTE_ADDR};
#      my $dbh=get_dbh;
#      my $sth=$dbh->prepare_cached("SELECT `name` from `usersession` WHERE `auth` = 1 AND `sessionid` = ? AND `ip` = ?");
#      my $aref=$dbh->selectall_arrayref($sth, {}, $session, $ip);
#      if($aref and (my $a=$$aref[0])) {
#         $authname=$$a[0];
#      }
#   }
#   return $authname;
}

sub getusernamecookie()
{
   cookie('user')||getauthname();
}
sub getuseridcookie()
{
   playername2id(cookie('user'))||getauthpid();
}

sub is_startofround()
{
# 91 is a good approximate of a quarter year because 4*91 = 364
   return $startofround; #((gmtime())[7]%91) <21;
}
sub is_admin()
{
   my $n=getauthname();
   if(!$n){return}
   return $adminlist{$n};
}

sub is_extended()
{
   return $ENV{REMOTE_USER} && $ENV{REMOTE_USER} ne "guest";
}

sub is_founder($)
{
   my ($pid)=@_;
   if(!$pid) {return 0}
   my($delegate)=get_one_row("SELECT alliaccess.pid FROM `alliaccess`,player WHERE alliaccess.alliance=player.alliance AND alliaccess.pid=player.pid AND player.pid=?",[$pid]);
   if($delegate) {return 1}
   my($founder)=get_one_row("SELECT founder FROM alliances, player WHERE aid=alliance AND pid=?",[$pid]);
   return $pid == $founder;
#   my $aid=playerid2alliance($pid);
#   if($aid && $awinput::alliances{$aid} && $awinput::alliances{$aid}->{founder}==$pid) {
#      return 1;
#   }
#   return 0;
}

# input: atag 
# in env: $ENV{REMOTE_USER}
# output: (status,info) , undef if not found
sub getallirelation($) {
	my($atag)=@_;
	my($status,$info)=get_one_row("SELECT `status`,`info` FROM `allirelations` WHERE `alli` = ? AND `tag` = ?", [$dbnamer, $atag]);
	return($status,$info);
}

sub getallrelations()
{
	my $dbh=get_dbh();
	my $sth=$dbh->prepare("SELECT * FROM `relations` WHERE `alli`=?");
	my $res=$dbh->selectall_arrayref($sth, {}, $dbnamer);
	return $res;
}
sub getallrelationkeys()
{
	my $r=getallrelations();
	my @keys=();
	foreach my $e (@$r) {
		push(@keys, lc(playerid2name($e->[0])));
	}
	return \@keys;
}

sub getrelation($;$) { my($name)=@_;
	my $lname="\L$name";
	my $pid=playername2idm($name);
	if(!$pid) { return }
	my $rel=get_one_rowref("SELECT * FROM `relations` WHERE `pid`=? AND `alli`=?", [$pid, $dbnamer]);
	my ($effrel,$ally,$info,$realrel,$hadentry);
	$hadentry=0;
	if($rel) {
		($effrel,$ally,$info)=@{$rel}[2,3,6];
		$hadentry=1
	}
	while(!$rel || !$effrel) {
		my $aid=$player{$pid}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel) {$atag=$ally;$aid=-1;}
      if(!$aid) {
        if($startofround) { $atag=playerid2lasttag($pid); if($atag){$aid=-2} }
      }
		elsif($aid>0) {$ally=$atag=$alliances{$aid}{tag};}
		if(!$aid) { return undef }
		
#		print "id $id a $aid at $atag\n<br>";
		my($status)=getallirelation($atag);
		if(defined($status)) {
         if($aid==-2){$atag=undef} # no real tag when using tag from last round
			return($status,$atag,$info,0,$hadentry,$lname)
		}
		if(!$rel) { return undef }
		last;
	}
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel,1,$lname);
}
sub playerid2relation($) { my($pid)=@_;
   return getrelation(playerid2namem($pid));
}
sub setrelation($%) { my($id,$options)=@_;
	if(!$id) {$id=$$options{name}}
	#print "set '$id', '$options' $dbnamer ";
   my $pid=playername2idm($id);
   if($pid) {  # mysql relations insert
      my $dbh=get_dbh;
      my $alli=$dbnamer||$ENV{REMOTE_USER};
      if(!$options) {
         my $sth=$dbh->prepare("DELETE FROM `relations` WHERE `pid`=? AND `alli`=?");
         $sth->execute($pid, $alli);
      } else {
         my $sth=$dbh->prepare("REPLACE INTO `relations` VALUES (?,?,?,?,?,?,?)");
         $sth->execute($pid, $alli, $$options{status}, $$options{atag}, 0, time(), $$options{info});
      }
   }
}
sub setallirelation(%)
{
	my($options)=@_;
	my $dbh=get_dbh();
	my $sth=$dbh->prepare("REPLACE INTO allirelations VALUES (?,?,?,?)");
	$sth->execute(lc($options->{p}),$dbnamer||$ENV{REMOTE_USER},$options->{relation},$options->{comment});
}

sub playerid2etc($) { my($id)=@_;
   return undef if not $id;
   my $iir=playerid2iir($id);
   return $iir->[10];
}
sub playername2etc($) { my($name)=@_;
   return playerid2etc(playername2idm($name));
}
sub playername2etc_old($) { my($name)=@_;
   my @rel=getrelation($name);
   if($rel[2]) {
      my @sci=relation2science($rel[2]);
      if($sci[8]) { return $sci[8] }
   }
   return undef;
}

sub playername2id($) { my($name)=@_;
#	print qq!$name = $playerid{"\L$name"}\n!;
	$playerid{"\L$name"};
}
sub playerid2lasttag($) { my($pid)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT `lasttag` FROM `playerextra` WHERE `pid` = ? LIMIT 1");
   my $r=$dbh->selectall_arrayref($sth, {}, $pid);
   if($r && $r->[0]) {
      return $r->[0]->[0];
   }
   return undef;
}
sub playername2idm($) { my($name)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT pid FROM `playerextra` WHERE `name` = ? LIMIT 1");
   my $r=$dbh->selectall_arrayref($sth, {}, $name);
   if($r && $r->[0]) {
      return $r->[0]->[0];
   }
   if($startofround) {
      return playername2idaw($name);
   }
   return undef;
}
sub playername2idaw($) { my($name)=@_;
   if(!$name || $name eq "unknown") { return undef }
   return undef;
   require LWP::Simple;
   print STDERR "fetching name=$name from AW\n";
   my $html=LWP::Simple::get("http://www.astrowars.com/forums/profile.php?mode=viewprofile&u=$name");
   if($html=~m!playerprofile\.php\?id=(\d+)" class="genmed"> Public </a>!) {
      my $id=$1;
      my $premium;
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', ?)!);
      $sth->execute($id, $name, $premium);
      return $id;
   }
   return undef;
}
sub playername2idaw2($) { my($name)=@_;
   if(!$name || $name eq "unknown") { return undef }
   require LWP::Simple;
   print STDERR "fetching name=$name from AW\n";
   my $html=LWP::Simple::get("http://www1.astrowars.com/about/playerprofile.php?name=$name");
   if($html=~m!<tr><td colspan="2"><a href=http://www\.astrowars\.com/forums/privmsg\.php\?mode=post&u=(\d+)>Send Private Message</a></td></tr>!) {
      my $id=$1;
      my $premium=($html=~m!<br><small>Premium Member</small>! ? 1:0);
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', ?)!);
      $sth->execute($id, $name, $premium);
      return $id;
   }
   return undef;
}
sub playerid2nameaw($) { my($id)=@_;
   require LWP::Simple;
   my($max)=get_one_row("SELECT max( `pid` ) FROM `playerextra`");
# sanity check: IDs are positive and rising slowly
   if($id<0 || ($max && $max>200000 && $id>$max+2000)) {return undef}
   print STDERR "fetching id=$id from AW\n";
   my $html=LWP::Simple::get("http://www.astrowars.com/forums/profile.php?mode=viewprofile&u=$id");
   if($html=~m!Sorry, but that user does not exist! || $html=~m!<span class="gen">Contact ([^<>]{1,25}) </span>!) {
      my $name=$1||"";
      if($name=~m/\S/) {
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', ?)!);
      $sth->execute($id, $name, undef);
      }
      return $name;
   }
   return undef;
}
# old/unused active player fetcher
sub playerid2nameaw2($) { my($id)=@_;
   require LWP::Simple;
   print STDERR "fetching id=$id from AW\n";
   my $html=LWP::Simple::get("http://www1.astrowars.com/about/playerprofile.php?id=$id");
   if($html=~m/^<html><head><title>([^\n<>]{1,25}) - profile/) {
      my $name=$1;
      my $premium=($html=~m!<br><small>Premium Member</small>! ? 1:0);
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', ?)!);
      $sth->execute($id, $name, $premium);
      return $name;
   }
   return undef;
}
sub playerid2namem($) { my($id)=@_;
   if(!defined($id)) {return undef}
#   if($id<=2) {return "unknown"}
   my ($name)=get_one_row("SELECT `name` FROM `playerextra` WHERE `pid` = ? LIMIT 1", [$id]);
   if(defined($name)) {
      return $name;
   }
   if($startofround) {
      return playerid2nameaw($id);
   }
   return undef;
}
sub playerid2name($) { my($id)=@_;
	if(!defined($id)) {return "unknown"}
	if($id<=2 || !$player{$id}) {return "unknown"}
	$player{$id}{name};
}
sub playerid2home($) { my($id)=@_;
	if(!defined($id)) {return undef}
	if($id<=2 || !$player{$id}) {return undef}
	$player{$id}{home_id};
}
sub playerid2country($) { my($id)=@_;
	$player{$id}{from};
}

sub sidpid2planetm($)
{ my($sidpid)=@_;
	my $r=get_one_rowref("SELECT * FROM `planets` WHERE `sidpid`=?", [$sidpid]);
	if(!$r) {return undef}
	return {systemid=>sidpid2sidm($sidpid), planetid=>sidpid2pidm($sidpid), "pop"=>$r->[1], opop=>$r->[2], sb=>$r->[3], ownerid=>$r->[4], s=>$r->[5]};
}
sub getplanetm($$) {my($sid,$pid)=@_;
	return sidpid2planetm(sidpid22sidpid3m($sid,$pid));
}
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$planets{$sid};
	if(!$sys) {return undef}
	$$sys[$pid-1];
}
sub getplayer($) { my($playerid)=@_;
	return $player{$playerid};
}
sub getalliance($) { my($aid)=@_;
	return $alliances{$aid};
}

# input: valid pid
# output: string with pseudo-tag from real tag, tools tag or last rounds tag
sub playerid2pseudotag($) { my($id)=@_;
   my $name=playerid2namem($id);
   my @rel=getrelation($name);
   my $alli="";
   my $atag=playerid2tag($id);
   if($atag) {$alli="[$atag] "}
   elsif($rel[1]) {$alli="[$rel[1]] "}
   else {
      my $atag=playerid2lasttag($id);
      if($atag) {$alli="[($atag)] "}
   }
   return $alli;
}
sub playerid2link($) { my($id)=@_;
   if(!defined($id)) {return "???"}
   if($id==0) {return "free planet"}
   my $name=playerid2namem($id);
   $name=~s/O/o/g;
   $name=~s/I/i/g;
   my @rel=getrelation($name);
   my $col=getrelationclass($rel[0]);
   my $alli=playerid2pseudotag($id);
   return a({-href=>$toolscgiurl."relations?id=$id", -class=>"$col"}, "$alli$name");
}

sub playerid2link2($) {   
   my $l=playerid2link($_[0]);
   $l=~s!${toolscgiurl}relations!http://$awserver/0/Player/Profile.php/!;
   return $l;
}

sub systemid2link($) { 
   display_sid($_[0]);
}

sub getplanetinfom($$) { my($sid,$pid)=@_;
   my ($allimatch, $amvars)=get_alli_match2($ENV{REMOTE_USER},2);
   my $sidpid=sidpid22sidpid3m($sid,$pid);
   return get_one_rowref(
      "SELECT planetinfos.* FROM `planetinfos`,toolsaccess 
      WHERE sidpid=? AND $allimatch ORDER BY modified_at DESC LIMIT 1", [$sidpid,@$amvars]);
}
sub getplanetinfo($$;$) { my($sid,$pid)=@_;
	my $id="$sid#$pid";
   my $pim=getplanetinfom($sid,$pid);
   if(!$pim || !defined($pim->[0])) {return ()}
   return ($pim->[3],$pim->[4],$pim->[8],$id);
}
sub setplanetinfo($%) { my($id,$options)=@_;
	if(!$id) {$id=$$options{sidpid}}
   if(!$id) {return}
	my $idm=sidpid22sidpid3m(sidpid32sidpid2($id));
	my $dbh=get_dbh;
	if(!$options) {
		my $sth=$dbh->prepare_cached("DELETE FROM `planetinfos` WHERE sidpid = ?");
		$sth->execute($idm);
;
	} else {
      $$options{status}||=0;
      $$options{who}||=0;
      $$options{info}||="";
		my $authpid=getauthpid();
		my $sth=$dbh->prepare_cached("INSERT INTO `planetinfos` VALUES ('',?,?,?,?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), ?) ON DUPLICATE KEY UPDATE modified_at = UNIX_TIMESTAMP(), status = ?, who = ?, modified_by = ?, info = ?");
		$sth->execute($ENV{REMOTE_USER},$idm, 
		$$options{status},$$options{who}, $authpid, $$options{info},
		$$options{status},$$options{who}, $authpid, $$options{info});
	}
}
sub systemname2id($) { my($name)=@_;
   if($name=~m/^\((\d+)\)$/) { return $1 }
	$name=~s/\s+/ /;
	return int($starmap{"\L$name"}||0);
}
sub systemcoord2id($$) { my($x,$y)=@_;
	return int($starmap{"$x,$y"}||0);
}
sub systemid2name($) { my($id)=@_;
	$starmap{$id}?$starmap{$id}{name}:undef;
}
sub systemid2level($) { my($id)=@_;
	$starmap{$id}?$starmap{$id}{level}:undef;
}
sub systemid2coord($) { my($id)=@_;
	$starmap{$id}?($starmap{$id}{x},$starmap{$id}{y}):undef;
}
sub systemid2planets($) { my($id)=@_;
        $planets{$id}?@{$planets{$id}}:undef;
}
sub allianceid2tag($) { my($id)=@_;
	($id && $alliances{$id})?$alliances{$id}{tag}:undef;
}
sub allianceid2members($) { my($id)=@_;
        ($alliances{$id} && $alliances{$id}{m})?@{$alliances{$id}{m}}:undef;
}
sub allianceid2membersr($) { my($id)=@_;
        $alliances{$id}?$alliances{$id}{m}:undef;
}
sub alliancetag2id($) { my($tag)=@_;
        $alliances{"\L$tag"}	#?$::alliances{$id}{tag}:undef;
}
sub playerid2alliance($) { my($id)=@_;
	$player{$id}?$player{$id}{alliance}:undef;
}
sub playerid2alliancem($) { my($id)=@_;
   return (get_one_row("SELECT `alliance` FROM `player` WHERE `pid`=?",[$id]))[0];
}
sub playerid2tagm($) { my($id)=@_;
   return (get_one_row("SELECT `tag` FROM `player`,`alliances` WHERE `pid`=? AND `alliance`=`aid`",[$id]))[0];
}
sub playerid2planets($) { my($id)=@_;
        $player{$id}?@{$player{$id}{planets}}:undef;
}
sub playerid2planetsm($) { my ($pid)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT `sidpid` FROM `planets` 
         WHERE ownerid = ?
         ORDER BY population DESC 
         ");
   my $aref=$dbh->selectall_arrayref($sth, {}, $pid);
   if(!$aref) {return ()}
   my @result=();
   foreach my $row (@$aref) {
      push(@result, &sidpid22sidpid3(sidpid32sidpid2m($row->[0])));
   }
   return @result;
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
sub planet2owner($) { my($h)=@_;
        $h?$$h{ownerid}:undef;
}
sub planet2siege($) {my($h)=@_;
	$h?$$h{s}:undef;
}
sub planet2pid($) {${$_[0]}{planetid}}
sub planet2sid($) {${$_[0]}{systemid}}
sub planet2pidm($) {my($h)=@_;$h?(($$h{sidpid})%13):undef}
sub planet2sidm($) {my($h)=@_;$h?int(($$h{sidpid})/13):undef}
sub sidpid2sidm($) {my($sidpid)=@_;int($sidpid/13) }
sub sidpid2pidm($) {my($sidpid)=@_;$sidpid%13 }

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
sub sidpid32sidpid2($) { split('#', $_[0]) }
sub sidpid22sidpid3m($$) {return $_[0]*13+$_[1];}
sub sidpid32sidpid2m($) {return (int($_[0]/13), $_[0]%13)}


our @bonusmap=(3,1,2,0); # prod sci cul grow

sub playerid2production($) { my($pid)=@_;
   next unless $pid;
   my($race,$sci)=playerid2ir($pid);
   return unless $race && @$race;
	for(my $i=0; $i<7; ++$i){$race->[$i]+=0;$race->[$i]*=$racebonus[$i]}
   my @prod=(undef,undef,undef,undef,undef,undef,undef);
   my $t=0;
   my @bonus=(1,1,1,1);
   my $iir=playerid2iir($pid);
   for my $i(0..3) {$race->[$i]+=1}
	if($iir) {
	   @prod=@{$iir}[3..9];
      my $a=$prod[3];
      $t=$prod[4]*0.01;
      if($a=~/(\w+)(\d)/) {
         my $effect=$artifact{$1}||0;
         for(my $i=0; $i<@$race; ++$i) {
            if((1<<$i) & $effect)
            {$race->[$i]*=1+0.1*$2}
#            {$race->[$i]+=0.1*$2} old GE9
         }
      }
   }
   { # for extended users without tag
      if($pid && (my $p=$player{$pid})) {
         my($t2)=get_one_row("SELECT `trade` FROM `tradelive` WHERE `pid`=?", [$pid]);
	 if(defined($t2)) {
	    $t=$t2*0.01;
         }
      }
   }
   for(my $i=0; $i<4; ++$i){
      $bonus[$i]=$race->[$bonusmap[$i]]*(1+$t);
   }
	if($player{$pid}{points}>=500) {$bonus[3]=0.01} # countdown -99% rule
	push(@prod, \@bonus);
#	for(my $i=0; $i<3; ++$i){ $prod[$i]+=$bonus[$i]; }
	return \@prod;
}
sub relation2production_old($;$) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
   my $name=$_[1];
	my @race=relation2race($_[0]);
	return undef unless @race;
	for(my $i=0; $i<7; ++$i){$race[$i]+=0;$race[$i]*=$racebonus[$i]}
   my @prod=(undef,undef,undef,undef,undef,undef,undef);
   my $t=0;
   my @bonus=(1,1,1,1);
	if(/production:(\S*)/) {
	   @prod=split(",", $1);
      my $a=$prod[3];
      $t=$prod[4]*0.01;
      if($a=~/(\w+)(\d)/) {
         my $effect=$artifact{$1}||0;
         for(my $i=0; $i<@race; ++$i) {
            if((1<<$i) & $effect)
            {$race[$i]+=0.1*$2}
         }
      }
   } else { # for extended users without tag
      my $pid=playername2id($name);
      if($pid && (my $p=$player{$pid})) {
         $t=$p->{trade}*0.01;
      }
   }
   foreach my $b (@bonus) {$b+=$t}
	$bonus[0]+=$race[3]; # prod
	$bonus[1]+=$race[1]; # sci
	$bonus[2]+=$race[2]; # cul
	$bonus[3]+=$race[0]; # grow
	push(@prod, \@bonus);
#	for(my $i=0; $i<3; ++$i){ $prod[$i]+=$bonus[$i]; }
	return @prod;
}


# return all know production values, PP/A$,artifact
sub playername2production($)
{
   my($name)=@_;
   return if not $name;
   return playerid2production(playername2idm($name));
#   my $rel=$relation{lc($name)};
#   return if not defined $rel;
#   return relation2production($rel,$name);
}

# differs from old getallproductions by 3 things: 
# - pid is returned instead of name
# - bonus is given directly
# - result is returned as ref
sub getallproductionsm()
{
   my $dbh=get_dbh;
   my ($allimatch, $amvars)=get_alli_match2($ENV{REMOTE_USER},32, "internalintel.alli");
   my $sth=$dbh->prepare("SELECT intelreport.pid,internalintel.production,ad,pp,
         (intelreport.production*$racebonus[3]+1+0.01*tr),artifact 
         FROM `internalintel`,intelreport,toolsaccess 
         WHERE intelreport.pid=internalintel.pid AND intelreport.alli=internalintel.alli AND $allimatch");
   my $p=$dbh->selectall_arrayref($sth, {}, @$amvars);
   foreach my $prod (@$p) {
      $prod->[5]=~m/(.*)(\d)/;
      my $e=$artifact{$1}&8;
      $prod->[4]+=($e>>3)*$2*0.10; # add artifact to prod
   }
   return $p||[];
}

# input: artifact name (BM1)
# output: number (e.g. 3851.28 A$)
sub getartifactprice($)
{
	my($arti)=@_;
	if(!$arti) {return 0}
	return ((get_one_row("SELECT `price` FROM `prices` WHERE `item`=?", [$arti]))[0]);
}

# input: pid
# output: array of trade partner IDs
sub playerid2trades($) {
   my ($pid)=@_;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT * FROM `trades` WHERE `pid1` = ? OR `pid2` = ? ORDER BY `time`");
   my $t=$dbh->selectall_arrayref($sth, {}, $pid, $pid);
   my @t=();
   foreach my $row (@$t) {
      my($pid1,$pid2)=@$row;
      push(@t, (($pid1==$pid)?$pid2 :$pid1));
   }
   return @t;
}

sub _playerid2alli($)
{ 
   return (get_one_row("SELECT alli FROM useralli WHERE pid=?",[$_[0]]))[0];
}

sub playerid2alli($) { my($pid)=@_;
	if(!$pid) {return ""}
   my $alli=_playerid2alli($pid);
   if(!$alli) {
#      local $ENV{REMOTE_USER};
#      tie %alliances, "MLDBM", "$dbdir/alliances.mldbm", O_RDONLY, 0666;
#      tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDONLY, 0666;
      if($pid && $pid>2) {
         $alli=lc(playerid2tagm($pid));
         if($awaccess::remap_alli{$alli}) { $alli=$awaccess::remap_alli{$alli} }
         if(!is_allowedalli($alli)) {$alli=""}
      }
   }
   return $alli;
}

# this function is intended to work without init
sub playername2alli($) {my ($user)=@_;
   if(!$user) {return ""}
   return playerid2alli(playername2idm($user));
}


# add a number of trades for a certain player id
sub add_trades($@)
{
   my($ownpid,$otherpids)=@_;
   my $dbh=get_dbh;
#   my $sth=$dbh->prepare_cached("SELECT pid1,pid2 FROM `trades` WHERE `pid1` =  ? OR `pid2` = ?");
#   my $old=$dbh->selectall_arrayref($sth, {}, $ownpid, $ownpid);
#   my %oldmap;
   my $now=time();
#   if($old) {
#      foreach my $row (@$old) {
#         my @a=@$row;
#         $oldmap{"$a[0],$a[1]"}=1;
#      }
#   }
   my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `trades` VALUES (?, ?, ?)!);
   my $sth2=$dbh->prepare_cached(qq!INSERT IGNORE INTO `alltrades` VALUES ('', ?, ?)!);
   foreach my $xpid (@$otherpids) {
      my $pid1=awmax($xpid,$ownpid);
      my $pid2=awmin($xpid,$ownpid);
      #next if($oldmap{"$pid1,$pid2"}); # do not re-add existing entries
      # pid1 is always larger than pid2
      my $result=$sth->execute($pid1, $pid2, $now);
      $sth2->execute($pid1, $pid2);
      $sth2->execute($pid2, $pid1);
   }
}


our $fleetscreen="uninitialized";
# prepare DB for adding planet/planning info
# input: screen = integer identifying source of data (1=system-info, 2=cleanplanning)
sub dbplanetaddinit(;$) { my($screen)=@_;
}
# prepare DBs for adding new fleets
# input pid = player ID of whose fleets are viewed
# input screen = 0=news, 1=fleets 2=alliance_incomings 3=alliance_detail 4=alliance_detail_incoming 8=planet_detail
sub dbfleetaddinit($;$) { my($pid,$screen)=@_; $screen||=0;
   $awinput::fleetscreen=$screen;
   return unless $ENV{REMOTE_USER};
#   awdiag("name:$::options{name} scr:$screen awscr:$awinput::fleetscreen");
   if($pid) {
      my $dbh=get_dbh;
      my $cond="";
      if($screen==1) {$cond=" AND ( `trn` != 0 OR `cls` != 0 OR `ds` != 0 OR `cs` != 0 OR `bs` != 0 ) "}
      my $sth=$dbh->prepare_cached("UPDATE `fleets` SET `iscurrent` = 0 WHERE `alli` = ? AND `owner` = ? $cond");
      $sth->execute($ENV{REMOTE_USER}, $pid);
   } 
}
# type: 0=siege, 1=defending, 2=incoming 3=moving own
sub dbfleetadd($$$$$$@;$) { my($sid,$pid,$plid,$name,$time,$type,$fleet,$tz)=@_;
   return unless $ENV{REMOTE_USER};
   if(! defined($tz)) {$tz=$::options{tz}}
   if($time) {$time-=3600*$tz}
   {
#      local $^W=0;
      require "fleetadd.pm"; my $ret=fleetadd::dbfleetaddmysql($sid,$pid,$plid,$name,$time,$type,$fleet,$tz,$awinput::fleetscreen);
      if($ret==1) {  # there was a new fleet and we need to check+update plannings
         my @pinfo=getplanetinfo($sid,$pid);
         if($pinfo[1] == $plid) {
            my ($s,$info)=@pinfo[0,2];
            my $sidpid=sidpid22sidpid3($sid,$pid);
            my $d=AWisodate(time());
            if($time) { # moving fleet: planned to targeted
               if($s==2) {
                  $s=3;
                  $info="l:$d $info";
               }
            } else { # resting fleet: targeted to sieged
               my $newstat=($type==0?4:5); # or to taken if fleet is on own planet
               my $oldstat=($type==0?3:qr([34]));
               my $text=($type==0?"s":"took").":";
					if($type==0) {
						if($s==3) {
							$s=4;
							$info="s:$d $info";
						}
					} else {
						if($s==3 || $s==4) {
							$s=5;
							$info="took:$d $info";
						}
					}
            }
            setplanetinfo($pinfo[3], {status=>$s, who=>$plid, info=>$info});
         }
      }
   }
   return 0;
}
sub dbfleetaddfinish() {
}

sub dbplayeriradd($;@@@@@) { my($name,$sci,$race,$newlogin,$trade,$prod)=@_;
   return if(!is_extended());
#	my @rel=getrelation($name);
#	my $oldentry="$rel[0] $rel[1] $rel[2]";# TODO $relation{$name};
#	my $newentry=addplayerir($oldentry, $sci,$race,$newlogin,$trade,$prod);
#	if($newentry) {
#		if($::options{debug}) {print "<br />$name new:",$newentry;}
	{
		my $pid=playername2idm($name);
      require awlogins;
      awlogins::add_login($ENV{REMOTE_USER}, $pid, $newlogin);
#      print STDERR "$pid @$sci\n";
      my $etc=$sci->[7]; # TODO check if sci array is modified in awstandard::addplayerir
      my $dbh=get_dbh;
      my $time=time();
		if($pid && $race && defined($race->[0])) {
			my @sci=(undef,undef,undef,undef,undef,undef);
			my @race=(undef,undef,undef,undef,undef,undef,undef, undef,undef);
			if($race && defined($race->[0])) {
				@race=@{$race}[0..6];
				my $sum=0;
				foreach my $r (@race){$sum+=$r}
				$race[7]=$sum<=-$tradercost;
            if($race[7]){$sum-=$tradercost}
				$race[8]=$sum&1;
			}
			my @update=map {"$_=?"} (@awstandard::racestr, "trader", "startuplab");
			my $sth=$dbh->prepare_cached("INSERT INTO `intelreport` 
               VALUES (?,?,?, ?,?,?,?,?,?,?, ?,?, ?,?,?,?,?,?,1) 
               ON DUPLICATE KEY UPDATE modified_at=?, racecurrent=1, ".join(", ", @update));
			$sth->execute($ENV{REMOTE_USER},$pid,
				$time, @race, @sci,
				$time, @race);
		}
      if($pid && $sci && defined($sci->[1])) {
         my @sci;
			if($sci) {@sci=@{$sci}[0..5]}
         my $sth=$dbh->prepare("UPDATE `intelreport` 
            SET racecurrent=1, biology=?, economy=?, energy=?, mathematics=?, physics=?, social=?, modified_at=?
            WHERE `alli`=? AND `pid`=?");
         my $r=$sth->execute(@sci, $time, $ENV{REMOTE_USER},$pid);
      }
      if($pid && $prod) {
         my $sth=$dbh->prepare("INSERT INTO `internalintel`
               VALUES(?,?,?,?,?,?,?,?,?,?,?,0)
               ON DUPLICATE KEY UPDATE
                  modified_at=VALUES(modified_at), ad=VALUES(ad), pp=VALUES(pp), artifact=VALUES(artifact), tr=VALUES(tr), production=VALUES(production), science=VALUES(science), culture=VALUES(culture)");
         $sth->execute($ENV{REMOTE_USER},$pid,$time,@{$prod},$etc);
      }
      if($pid && $sci && $etc) {
         my $sth=$dbh->prepare("UPDATE `internalintel` SET `etc`=? WHERE `alli`=? AND `pid`=?");
         my $r=$sth->execute($etc, $ENV{REMOTE_USER},$pid);
      }
   }
}

sub dblinkadd { my($sid,$url)=@_;
   my $type;
   if($url=~m!http://forum\.rebelstudentalliance\.co\.uk/index\.php\?showtopic=(\d+)!) { $type="RSA" } # IPB
   if($url=~m!http://home\.rebelstudentalliance\.co\.uk/forum/index\.php/topic,(\d+\.\d+)\.html!) { $type="RSA" } # IPB
   elsif($url=~m!http://flebb\.servebeer\.com/sknights/index\.php\?showtopic=(\d+)!) { $type="SK" } # IPB
   elsif($url=~m!http://z10.invisionfree.com/Trolls/index.php\?showtopic=(\d+)!) { $type="TROL" } # IPB
   elsif($url=~m!http://s6.invisionfree.com/LOVE/index.php\?showtopic=(\d+)!) { $type="LOVE" } # IPB
#   elsif($url=~m!http://xtasisrebellion\.free\.fr/phpnuke/modules\.php\?name=Forums&file=viewtopic&t=(\d+)!) { $type="XR" } # hacked and outdated
   elsif($url=~m!http://xtasisrebellion\.xt\.ohost\.de/forum/index\.php\?topic=([0-9.]+)!) { $type="XR" } # SMF
   elsif($url=~m!http://(?:www\.)?ionstorm-alliance\.org/index\.php\?topic=([0-9.]+)!) { $type="IS" } # SMF
   elsif($url=~m!http://www.anacronic.com/FIR/index.php\?topic=([0-9.]+)!) { $type="FIR" } # SMF
   elsif($url=~m!http://frozenstar.zoreille.info/index.php\?topic=([0-9.]+)!) { $type="FrS" } # SMF
   elsif($url=~m!http://www.aw-oceans11.de/smf/index.php\?topic=([0-9.]+)!) { $type="OXI" } # SMF
   elsif($url=~m!http://www.apgaming.com/index.php\?[a-zA-Z0-9&=_]topic=([0-9.]+)!) { $type="APG" } # SMF mod?
#   elsif($url=~m!http://lesnains\.darkbb\.com/viewtopic\.forum\?[pt]=(\d+)!) { $type="NAIN" } # phpBB outdated
   elsif($url=~m!http://tzar\.info/modules\.php\?name=Forums&file=viewtopic&[pt]=(\d+)!i) { $type="TZAR" } # phpNuke phpBB mod
   elsif($url=~m!http://lesnains\.darkbb\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="NAIN" } # some custom phpBB mod?
   elsif($url=~m!http://spin.forumzen.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="SpIn" } # some custom phpBB mod?
   elsif($url=~m!http://en\.forumactif\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="EN" } # some custom phpBB mod?
   elsif($url=~m!http://alien\.forum2jeux\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="AN" } # some custom phpBB mod?
   elsif($url=~m!http://mtg-aw\.forumzen\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="MtG" } # some custom phpBB mod?
   elsif($url=~m!http://quartiergeneral\.superforum\.fr/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="CRS" } # some custom phpBB mod?
   elsif($url=~m!http://cpgfh\.esc58\.com/+niai/viewtopic\.php.*!) { $type="NIAI" } # phpBB
   elsif($url=~m!http://quicheinside\.free\.fr/viewtopic\.php\?[pt]=(\d+)!) { $type="QI" } # phpBB
   elsif($url=~m!http://(?:www\.)vbbyjc\.com/phpBB2/viewtopic\.php\?[pt]=(\d+)!) { $type="SW" } # phpBB
   elsif($url=~m!http://www\.atfreeforum\.com/pikansjos/viewtopic\.php\?[pt]=(\d+)!) { $type="UFO" } # phpBB
   elsif($url=~m!http://sw\.wirleo\.com/viewtopic\.php\?[pt]=(\d+)!) { $type="SW" } # phpBB
   elsif($url=~m!http://allianceffa.free.fr/ZeForum/viewtopic\.php\?[pt]=(\d+)!) { $type="FFA" } # phpBB
   elsif($url=~m!http://www.ionstorm-alliance.com/forum/viewtopic\.php\?[pt]=(\d+)!) { $type="IS" } # phpBB
   elsif($url=~m!http://www.createforum.com/punx/viewtopic\.php\?[pt]=(\d+)!) { $type="PUNX" } # phpBB
   elsif($url=~m!http://holi87.webd.pl/forum/viewtopic\.php\?[pt]=(\d+)!) { $type="SoUP" } # phpBB
   elsif($url=~m!http://www.awocb.com/viewtopic\.php\?[pt]=(\d+)!) { $type="OCB" } # phpBB
   elsif($url=~m!http://87\.106\.97\.15/forum/blacksheep/viewtopic\.php\?[pt]=(\d+)!) { $type="BLA" } # phpBB
   elsif($url=~m!http://she.m-30.net/viewtopic\.php\?[pt]=(\d+)!) { $type="SHE" } # phpBB
   elsif($url=~m!http://lordvic.free.fr/ForumADN/viewtopic\.php\?[pt]=(\d+)!) { $type="ADN" } # phpBB
   elsif($url=~m!http://www.ouebomatik.net/forums/viewtopic\.php\?[pt]=(\d+)!) { $type="CPO" } # phpBB
   elsif($url=~m!http://www.varoquier.name/phpBB2/viewtopic\.php\?[pt]=(\d+)!) { $type="SSS" } # phpBB
   elsif($url=~m!http://whfoundation.7.forumer.com/viewtopic\.php\?[pt]=(\d+)!) { $type="WHF" } # phpBB
   elsif($url=~m!http://council.14.forumer.com/viewtopic\.php\?[pt]=(\d+)!) { $type="CoRE" } # phpBB
   elsif($url=~m!http://lba-lbb.iespana.es/viewtopic\.php\?[pt]=(\d+)!) { $type="LBA" } # phpBB
   elsif($url=~m!http://www\.astrowars\.com/forums/viewtopic\.php\?[pt]=(\d+)!) { $type="main AW" } # phpBB
   elsif($url=~m!http://www.fishandreef.com/brigada/modules.php\?(?:name=Forums&)?(?:file=viewtopic&)?t=(\d+)!) { $type="LBA" } # Version 2.0.7 by Nuke Cops
   return unless($sid && $type);
   $url=$&;
   my $info=qq!see also <a href="$url">this $type forum thread</a>!;
   my $sidpid=sidpid22sidpid3m($sid,0);
   my $dbh=get_dbh();
   my $sth=$dbh->prepare_cached("INSERT IGNORE INTO `planetinfos` VALUES(NULL,?,?,?,?, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), ?)");
   $sth->execute($ENV{REMOTE_USER}, $sidpid, 0,0, getauthpid(), $info);
}

sub playername2ir($) { playerid2ir(playername2idm($_[0])) }
sub playername2ir_old($) { my($name)=@_;
   return undef if !$name;
   my @rel=getrelation($name);
   return undef if !$rel[2];
   my $race=[relation2race($rel[2])];
   my $sci=[relation2science($rel[2])];
   if(!@$race) {$race=undef}
   if(!@$sci) {$sci=undef}
   return($race,$sci);
}

# input: player ID
# output: race,science array reference
sub playerid2ir($) { my($plid)=@_;
#   return playername2ir(playerid2name($plid));
   my ($allimatch, $amvars)=get_alli_match2($ENV{REMOTE_USER},4);
   my @r=get_one_row("SELECT intelreport.*,growth+science+culture+production+speed+attack+defense FROM `intelreport`,toolsaccess WHERE `pid`=? AND $allimatch ORDER BY `modified_at` DESC LIMIT 1", [$plid, @$amvars]);
   my @race=@r[3..9,-1,10..11,18];
   foreach my $m (@race[0..6]) {if(defined($m) && $m>=0){$m="+$m"}}
   return (\@race, [@r[2,12..17]]);
}

sub playerid2iir($) { my($plid)=@_;
   my ($allimatch, $amvars)=get_alli_match2($ENV{REMOTE_USER},32);
   return get_one_rowref("SELECT internalintel.* FROM `internalintel`,toolsaccess WHERE `pid`=? AND $allimatch ORDER BY `modified_at` DESC LIMIT 1", [$plid, @$amvars]);
}

# input integer player ID
# output array of worst case battle stats
# ($pl,$ener,$phys,$math,$speed,$att,$def)
# or undef if pid is invalid
sub playerid2battlestats($) {
   my $plid=shift;
   my $p=$player{$plid};
   return if not $p;
   my $sl=$p->{science};
   my ($pl,$ener,$phys,$math,$speed,$att,$def)=($p->{level}, $sl,$sl,$sl, +4,+4,+4);
   my ($race,$sci)=playerid2ir($plid);
   if($race && defined($$race[0])) {
      ($speed,$att,$def)=@$race[4..6];
   }
   if($sci && defined($$sci[0])) {
      if($$sci[0]>100) {shift @$sci}
      ($ener,$math,$phys)=@$sci[2..4];
   }
   return ($pl,$ener,$phys,$math,$speed,$att,$def);
}

# take into consideration worst case IR
sub estimate_xcv($$) { my($plid,$cv)=@_;
   return $cv if(!$plid || $plid<=2 || !defined($player{$plid}));
   my ($phys,$att)=($player{$plid}{science}, +4);
   my ($race,$sci)=playerid2ir($plid);
   if($race && defined($$race[5])) { # use phys+race or SL+4
      $att=$$race[5];
   }
   if($sci && defined($$sci[0]) && $$sci[0]>time()-4*24*3600) {
      $phys=$$sci[5];
   }
# phys adj values: 
# DS: (107518/100000-1)/5 = 0.015036 ... 0.01525 ?
# CS: (211633/1.25/100000-1)/40 = 0.0173266
# CS: (101715/100000-1)/1 = 0.01715
# BS: (107709/100000-1)/5 = 0.015418
   return int($cv*(1+$phys*0.01525)*(1+$awstandard::racebonus[5]*$att));
}

# input: alli
# output: SQL to match allies
sub get_alli_match_old($;$)
{
   my($alli,$n)=@_;
   $n||="alli"; # default used for fleets
   if(!$alli) { return "0" }
   my $allimatch="(`$n` = '$alli'";
   if($read_access{$alli}) {
      foreach my $a (@{$read_access{$alli}}) {
         $allimatch.=" OR `$n` = '$a'";
      }
   }
   return $allimatch.")";
}

sub get_team_pids($;$)
{
   my($team,$alli)=@_;
   $alli||=$ENV{REMOTE_USER};
   if(!$alli) {return []}
#   my $m="";
   my ($allimatch,$amvars)=("alliances.`tag` = ? AND alliances.tag=toolsaccess.tag AND alliances.tag=othertag", [$alli]);
   my($allimatch2,$amvars2)=("`alli` = ? AND alli=toolsaccess.tag AND alli=othertag", [$alli]);
   if($team) {
      ($allimatch,$amvars)=get_alli_match2($alli,16,'alliances.tag');
      ($allimatch2,$amvars2)=get_alli_match2($alli, 16);
   } else {
   }
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("
         (SELECT `pid` FROM alliances,player,toolsaccess 
         WHERE `aid` = `alliance` AND $allimatch
         )
         
         UNION DISTINCT
         (SELECT `pid` FROM useralli,toolsaccess
         WHERE $allimatch2)
         ");
   my $res=$dbh->selectcol_arrayref($sth, {}, @$amvars, @$amvars2);
   return $res;
}

sub get_all_brownie_pids
{
   my $dbh=get_dbh;
   my $res=$dbh->selectall_arrayref("SELECT pid FROM usersession GROUP BY usersession.pid");
}

# get all fleets visible to own alli
# input: SQL condition to add - defaults to ""
sub get_fleets2($;@) { my($cond, $vars)=@_;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   $vars||=[];
   $cond||="";
   my ($allimatch,$amvars)=get_alli_match2($alli,1);
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT fleets.* FROM `fleets`,toolsaccess WHERE ($allimatch) $cond");
   my $res=$dbh->selectall_arrayref($sth, {}, @$amvars, @$vars);
   return $res;
}

# input: sidpid
# input: SQL condition to add - defaults to ""
sub get_fleets($;$@) { my($sidpid,$cond, $vars)=@_;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   $vars||=[];
   $cond||="";
   my ($allimatch,$amvars)=get_alli_match2($alli,1);
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT fleets.* FROM `fleets`,toolsaccess WHERE ($allimatch) AND `sidpid` = ? $cond ORDER BY `eta` ASC, `lastseen` ASC");# AND `iscurrent` = 1");
   my $res=$dbh->selectall_arrayref($sth, {}, @$amvars, $sidpid, @$vars);
   return $res;
}
# same as get_fleets
sub sidpid2fleets($;$@) { my($sidpid,$cond,$vars)=@_;
   $vars||=[];
   $cond||="";
   return get_fleets2(" AND `sidpid` = ? $cond ORDER BY `eta` ASC, `lastseen` ASC", [$sidpid,@$vars]);
}
sub playerid2fleets($;$@) { my($pid,$cond,$vars)=@_;
   $vars||=[];
   $cond||="";
   return get_fleets2(" AND `owner` = ? $cond", [$pid,@$vars]);
}

sub get_fleet($) {
   my $fid=shift;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   my $dbh=get_dbh;
   my ($allimatch,$amvars)=get_alli_match2($alli, 1);
   my $sth=$dbh->prepare("SELECT fleets.* FROM `fleets`,toolsaccess WHERE `fid` = ? AND ($allimatch)");
   my $res=$dbh->selectall_arrayref($sth, {}, $fid, @$amvars);
   return $res;
}

sub fleet_launch_url($)
{ my($f)=@_;
	my %opts;
	my $sidpid;
	($sidpid, $opts{inf}, $opts{col}, $opts{des}, $opts{cru}, $opts{bat})=@$f[3,8..12];
	$opts{nr}=sidpid2sidm($sidpid);
	my $params=join("&", map {"$_=$opts{$_}"} sort keys %opts);
	return("http://$awserver/0/Fleet/Launch.php/?$params&id=".sidpid2pidm($sidpid));
}

our %fleetcolormap=(1=>"#777", 2=>"#d00", 3=>"#f77");
# input: 1 row from fleet table
# output: HTML for a short display of fleet with detailed info in title=
sub show_fleet($) { my($f)=@_;
   my $minlen=21;
   my $minlen1=34;
   #fid alli status sidpid owner eta firstseen lastseen trn cls ds cs bs cv xcv iscurrent info
   my($fid, $status, $sidpid, $owner, $eta, $firstseen, $lastseen, $trn, $cls, $cv, $xcv, $iscurrent, $info)=@$f[0,2,3..9,13..16];
   if($cv==0 && $cls==0 && $trn==0) {return ""}
   my $color=!$iscurrent;
   my $tz=$timezone*3600;
   my($sid,$pid)=sidpid32sidpid2m($sidpid);
   if($status==1) {
      my $p=getplanet($sid,$pid);
      if($p) {
         my $n=planet2sb($p);
         $xcv.="+".int(0.5+((-10+10*(1.5**$n))*0.4));
      }
   }
   my $flstr="$cv/$xcv CV";
   if($trn){$flstr.=", $trn TRN"; if($eta){$color|=2;}}
   if($cls){$flstr.=", $cls CLS";}
   if($color) {$color="; color:$fleetcolormap{$color}"}
   if(!$eta && $iscurrent){$color.="; text-decoration:underline"}
   if($status==2) {$color.="; background-color: orange"}
   if($status==10) {$color.="; background-color: violet"}
   my $tz2=($timezone>=0?"+":"").$timezone;
   if($eta) {$eta=AWisodatetime($eta+$tz)." GMT$tz2 ".awstandard::AWreltime($eta)} else {$eta="defending fleet.............."}
   if(length($eta)<$minlen1) {$eta.="&nbsp;" x ($minlen1-length($eta))}
   if(length($flstr)<$minlen) {$flstr.="&nbsp;" x ($minlen-length($flstr))}
   my $xinfo="$sid#$pid".": fleet=@$f[8..12] firstseen=".awstandard::AWreltime($firstseen)." lastseen=".awstandard::AWreltime($lastseen);
   if($info) {$info=" ".$info}
	my $launch="";
	if(1) {
		$launch=" ".a({-href=>fleet_launch_url($f)}, "launch");
	}
   return "<span style=\"font-family:monospace $color\" title=\"$xinfo\"><a href=\"${toolscgiurl}edit-fleet?fid=$fid\">edit</a> <a href=\"${toolscgiurl}fleetbattlecalc?fid=$fid\">bc</a> <a href=\"${toolscgiurl}whocanintercept?p=$sid%23$pid&amp;cvlimit=$cv\">catch</a>$launch $eta $flstr ".playerid2link($owner).$info."</span>";
}

sub playerid2plans($)
{ my($pid)=@_;
   my $dbh=get_dbh;
   my ($allimatch,$amvars)=get_alli_match2($ENV{REMOTE_USER}, 2);
   my $sth=$dbh->prepare("SELECT planetinfos.* FROM `planetinfos`,toolsaccess WHERE `who` = ? AND ($allimatch)");
   my $res=$dbh->selectall_arrayref($sth, {}, $pid, @$amvars);
   return $res;
}

sub showplan($)
{
   my($sidpid,$status,$who,$info)=@{$_[0]}[2..4,8];
   my($sid,$pid)=sidpid32sidpid2m($sidpid);
   return a({-href=>"planet-info?id=$sid%23$pid"},"$sid#$pid")." status=$status ".display_pid($who)." $info";
}

# support functions for sort_table
sub display_pid($) {
   playerid2link($_[0]);
}
sub display_relation($) { my($rel)=@_;
   my $c=getrelationcolor($rel);
   my $rn=$awstandard::relationname{$rel};
   return qq'<span style="background-color: $c">&nbsp;$rn&nbsp;</span>';
}
sub display_atag($) { my($atag)=@_;
   a({-href=>"alliance?alliance=$atag&omit=10+13+16"},$atag);
}
sub display_sid($) { my($sid)=@_;
   my ($x,$y)=systemid2coord($sid);
   a({-href=>"system-info?id=$sid"},"$sid($x,$y)");
}
sub display_sid2($;$) { my($sid,$pid)=@_;
   my $name=systemid2name($sid);
   return "" if ! $name;
   my ($x,$y)=systemid2coord($sid);
	my $extra=($pid?"&target=$pid":"");
   return a({-href=>"http://$bmwserver/cgi-bin/system-info?id=$sid$extra"},"$name ($x,$y)");
}

sub sort_pid($$) {lc(playerid2name($_[0])) cmp lc(playerid2name($_[1]))}

sub get_alli_group($)
{
   my($alli)=@_;
   my @list=($alli);
   return @list;
}

# input: playerid
sub getuserprefs($) { my($pid)=@_;
   return get_one_rowref("SELECT * FROM `playerprefs` WHERE `pid` = ?", [$pid]);
}

sub getallidetailurl($) { my($pid)=@_;
   my($aid,$arank)=get_one_row("SELECT alliance,arank FROM `player` WHERE `pid` = ?", [$pid]);
   if(!$arank || !$aid) {return}
   my $authpid=getauthpid();
   if($authpid) {
      if(playerid2alliance($authpid)!=$aid) {return}
   } elsif($ENV{REMOTE_USER} && lc(allianceid2tag($aid)) eq $ENV{REMOTE_USER}) { # use tag

   } else {return}
   $arank--;
   return "http://$awserver/0/Alliance/Detail.php/?id=$arank";
}

# input: alliance id
# output: arrayref with all
sub getlivealliscores($)
{
   my($aid)=@_;
   my $dbh=get_dbh();

   my $sth=$dbh->prepare("SELECT cdlive.points
      FROM `cdlive` , player
      WHERE cdlive.pid = player.pid
      AND `alliance`=?
      AND `time`>?
      ORDER BY `points` DESC");
   return $dbh->selectcol_arrayref($sth, {}, $aid, time()-12*3600);
}

sub settoolsaccess_rmask($$$) {
        my ($alli,$tag,$rmask)=@_;
	my $dbh=get_dbh();
	my $sth=$dbh->prepare("UPDATE `toolsaccess` SET rmask=? WHERE tag=? AND othertag=?");
	$sth->execute($rmask, $tag, $alli);
}

sub settoolsaccess($$$;$) {
        my ($alli,$tag,$rbits,$wbits)=@_;
	$wbits||=0;
	my $dbh=get_dbh();
	my $sth=$dbh->prepare("INSERT INTO `toolsaccess` VALUES (?,?,?,?,255) ON DUPLICATE KEY UPDATE rbits=?");
	$sth->execute($alli,$tag,$rbits,$wbits, $rbits);
}


# input: alliance id
# output: float score points value
#sub getlivealliscore($) see alliance tool

# input: player id
# output: UNIX timestamp of last login or undef if no current data is available
sub getlastlog($)
{
	my($pid)=@_;
	require awlogins;
	my $logins=awlogins::get_logins($ENV{REMOTE_USER}, $pid, "ORDER BY `n` DESC LIMIT 1");

	foreach my $log (@$logins) {
		my ($n,$time, $idle, $fuzz)=@$log;
		my $playerref=getplayer($pid);
		my $dblog=$playerref->{logins};
		if($n<$dblog) { return undef; } # stale/outdated data
#		print "@$log $dblog<br>\n";
		return $time;
	}
	return undef;
}

# input: player ID
# output: [floatpoppoints, poppoints, scipoints, plpoints, totalpp]
sub predict_points($)
{
	require awbuilding;
	my $id=shift;
	my $pl;
	if($id>2) {$pl=getplayer($id)}
	return undef unless $pl;
	my @pl=playerid2planetsm($id);
	my ($level,$pop,$scipoints)=get_one_row("SELECT level,`opop`,points-$plpointsfactor*level FROM `player` WHERE `pid` = ?", [$id]);
	my @planets;
	my $poppts=0;
# get pop points from CSV
	foreach my $p (@pl) {
		my $pp=getplanet2($p);
		push(@planets, $pp);
		my $ppop=planet2opop($pp);
		next if $ppop<10;
		$poppts+=$ppop-10;
		next if $ppop<20;
		$poppts+=$ppop-20;
	}

# get brownie data
	my $internalplanets=awbuilding::getbuilding_player($id);
	my %internalplanet;
	foreach my $ip (@$internalplanets) { # hash result array
		my $sidpid=shift(@$ip);
		$internalplanet{$sidpid}=$ip;
	}
	my($iptotalpp, $iptotalpop, $iiptotalpoppoints, $iptotalpoppoints);
	foreach my $pp (@planets) {
		my $sid=planet2sid($pp);
		my $pid=planet2pid($pp);
		my $sidpid=sidpid22sidpid3m($sid,$pid);
		my $ip=$internalplanet{$sidpid};
		my $ipextra="";
		if($ip) {
			my (undef,undef,undef,$ippop,$ippp)=@$ip;
			$iptotalpp+=$ippp;
			$iptotalpop+=$ippop;
			if($ippop>10) {
				my $iippop=int($ippop);
				$iptotalpoppoints+=$ippop-10;
				$iiptotalpoppoints+=$iippop-10;
				if($ippop>20) {
					$iptotalpoppoints+=$ippop-20;
					$iiptotalpoppoints+=$iippop-20;
				}
			}
		}
	}
# TODO: simulate extra science points
	if($iptotalpp && $iptotalpop) {
		return [$iptotalpoppoints, $iiptotalpoppoints, $scipoints-$poppts, $plpointsfactor*$level];
	}
	return undef;
}

1;
