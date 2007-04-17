#!/usr/bin/perl -w
package awinput;
use strict "vars";
require 5.002;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
our (%alliances,%starmap,%player,%playerid,%planets,%battles,%trade,%prices,%relation,%planetinfo,
   $dbnamer,$dbnamep);
my $startofround=1;
our $alarmtime=99;

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = qw(
&awinput_init &getrelation &setrelation &playername2id &playername2idm &playerid2name &playerid2namem &playerid2home &playerid2country &getplanet &playerid2lasttag &playerid2pseudotag &playerid2link &playerid2link2 &getplanetinfo &setplanetinfo &systemname2id &systemcoord2id &systemid2name &systemid2level &systemid2coord &systemid2link &systemid2planets &allianceid2tag &allianceid2members &alliancetag2id &playerid2alliance &playerid2planets &playerid2tag &planet2sb &planet2pop &planet2opop &planet2owner &planet2siege &planet2pid &planet2sid &getatag 
&sidpid2planet &getplanet2 &sidpid22sidpid3 &sidpid32sidpid2 &sidpid22sidpid3m &sidpid32sidpid2m 
&relation2production &gettradepartners &getartifactprice &getallproductions &dbfleetaddinit &dbfleetadd &dbfleetaddfinish &dbplayeriradd &dblinkadd &getauthname &is_admin &is_founder
&display_pid &display_relation &display_atag &display_sid &display_sid2 &sort_pid
%alliances %starmap %player %playerid %planets %battles %trade %relation %planetinfo
);


use MLDBM qw(DB_File Storable);
#use DBAccess;
use DB_File::Lock;
use CGI ":standard";
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY);
use awaccess;
use DBAccess2;
use awstandard;
my $head="Content-type: text/plain\015\012";

my %adminlist=(greenbird=>1);

sub awinput_init(;$) { my($nolock)=@_;
   awstandard_init();
#chdir "/home/aw/db"; # done by awstandard_init
# use absolute pathes from awstandard
   tie %alliances, "MLDBM", "$dbdir/alliances.mldbm", O_RDONLY, 0666 or die $!;
   tie %starmap, "MLDBM", "$dbdir/starmap.mldbm", O_RDONLY, 0666;
   tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDONLY, 0666;
   tie %playerid, "MLDBM", "$dbdir/playerid.mldbm", O_RDONLY, 0666;
   tie %planets, "MLDBM", "$dbdir/planets.mldbm", O_RDONLY, 0666;
   tie %battles, "MLDBM", "$dbdir/battles.mldbm", O_RDONLY, 0666;
   tie %trade, "MLDBM", "$dbdir/trade.mldbm", O_RDONLY, 0666;
   tie %prices, "MLDBM", "$dbdir/prices.mldbm", O_RDONLY, 0666;
   my $alli=$ENV{REMOTE_USER};
   if($alli) {
      my $a=$alli;
      if($remap_relations{$alli}) {
         $a=$remap_relations{$alli};
      }
      $dbnamer="$awstandard::dbmdir/$a-relation.dbm";
      if($remap_planning{$alli}) {
         $alli=$remap_planning{$alli};
      }
      $dbnamep="$awstandard::dbmdir/$alli-planets.dbm";
      untie %relation;
      untie %planetinfo;

#     if($ENV{REMOTE_USER} ne "guest") {
      if($nolock) {
         tie(%relation, "DB_File", $dbnamer, O_RDONLY, 0, $DB_HASH);
         tie(%planetinfo, "DB_File", $dbnamep, O_RDONLY, 0, $DB_HASH);
      } else {
         $SIG{"ALRM"}=sub{print STDERR "alarm $alarmtime; finish\n";&awinput_finish; require POSIX; POSIX::_exit(0);};
         alarm($alarmtime); # make sure locks are free'd
         tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
         tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
      }
   } else {
      # make sure it isnt tied and stored
      untie %relation;
      untie %planetinfo;
      %relation=();
      %planetinfo=();
   }
}


sub opendb($$%) {my($mode,$file,$db)=@_;
   tie(%$db, "DB_File::Lock", $file, $mode, 0, $DB_HASH, ($mode==O_RDONLY)?'read':'write');
#   or print $head,"\nerror accessing DB\n";
}

# release locks allocated in awinput_finish
sub awinput_finish() {
   untie(%relation);
   untie(%planetinfo);
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

sub is_admin()
{
   my $n=getauthname();
   if(!$n){return}
   return $adminlist{$n};
}

sub is_founder($)
{
   my ($pid)=@_;
   if(!$pid) {return 0}
   my $aid=playerid2alliance($pid);
   if($aid && $awinput::alliances{$aid} && $awinput::alliances{$aid}->{founder}==$pid) {
      return 1;
   }
   return 0;
}

sub getrelation($;$) { my($name)=@_;
	my $lname="\L$name";
	my $rel=$relation{$lname};
	my ($effrel,$ally,$info,$realrel,$hadentry);
	$hadentry=0;
	if($rel && $rel=~/^(\d+) (\w+) (.*)/s) {
		($effrel,$ally,$info)=($1, $2, $3);
		$hadentry=1
	}
	while(!$rel || !$effrel) {
#		if(!$rel) { return undef; }
		my $id=playername2idm($name);
		if(!$id) {
			if($hadentry){last}
			return undef
		}
		my $aid=$player{$id}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel) {$atag=$ally;$aid=-1;}
      if(!$aid) {
        if($startofround) { $atag=playerid2lasttag($id); if($atag){$aid=-2} }
      }
		elsif($aid>0) {$ally=$atag=$alliances{$aid}{tag};}
		if(!$aid) { return undef }
#		print "id $id a $aid at $atag\n<br>";
		my $rel2=$relation{"\L$atag"};
		if($rel2) { 
			$rel2=~/^(\d+) (\w+) /s;
         if($aid==-2){$atag=undef} # no real tag when using tag from last round
			return ($1,$atag,$info,0,$hadentry,$lname);
		}
		if(!$rel) { return undef }
		last;
	}
	$realrel=$effrel unless defined $realrel;
	return ($effrel,$ally,$info,$realrel,1,$lname);
}
sub setrelation($%) { my($id,$options)=@_;
	untie %relation;
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDWR, 0644, $DB_HASH, 'write') or die $!;
	if(!$id) {$id=$$options{name}}
	#print "set '$id', '$options' $dbnamer ";
	if(!$options) {delete $relation{$id}; }
	else {
		$relation{$id}="$$options{status} $$options{atag} $$options{info}";
	}
	untie %relation;
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0644, $DB_HASH, 'read') or die $!;
}

sub playername2etc($) { my($name)=@_;
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
   print STDERR "fetching id=$id from AW\n";
   my $html=LWP::Simple::get("http://www.astrowars.com/forums/profile.php?mode=viewprofile&u=$id");
   if($html=~m!<span class="gen">Contact ([^<>]{1,25}) </span>!) {
      my $name=$1;
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached(qq!INSERT IGNORE INTO `playerextra` VALUES (?, ?, '', ?)!);
      $sth->execute($id, $name, undef);
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
   if($id<=2) {return "unknown"}
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT `name` FROM `playerextra` WHERE `pid` = ? LIMIT 1");
   my $r=$dbh->selectall_arrayref($sth, {}, $id);
   if($r && $r->[0]) {
      return $r->[0]->[0];
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
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$planets{$sid};
	if(!$sys) {return undef}
	$$sys[$pid-1];
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
   my @rel=getrelation($name);
   my $col=getrelationclass($rel[0]);
   my $alli=playerid2pseudotag($id);
   return a({-href=>$toolscgiurl."relations?id=$id", -class=>"$col"}, "$alli$name");
}

sub playerid2link2($) {   
   my $l=playerid2link($_[0]);
   $l=~s!relations!http://www1.astrowars.com/0/Player/Profile.php/!;
   return $l;
}

sub systemid2link($) { 
   display_sid($_[0]);
}

sub getplanetinfo($$;$) { my($sid,$pid)=@_;
	my $id="$sid#$pid";
	my $pinfo=$planetinfo{$id};
	if(!$pinfo){return ()}
	$pinfo=~/^(\d) (\d+) (.*)/s;
	return ($1,$2,$3,$id);
}
sub setplanetinfo($%) { my($id,$options)=@_;
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDWR, 0644, $DB_HASH, 'write') or die $!;
	if(!$id) {$id=$$options{sidpid}}
   if(!$id) {return}
	#print "set '$id', '$options' $dbnamep ";
	if(!$options) {delete $planetinfo{$id}; }
	else {
      $$options{status}||=0;
      $$options{who}||=0;
      $$options{info}||="";
		$planetinfo{$id}="$$options{status} $$options{who} $$options{info}";
	}
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
}
sub systemname2id($) { my($name)=@_;
   if($name=~m/^\((\d+)\)$/) { return $1 }
	$name=~s/\s+/ /;
	$starmap{"\L$name"};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	$starmap{"$x,$y"};
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
sub playerid2planets($) { my($id)=@_;
        $player{$id}?@{$player{$id}{planets}}:undef;
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


sub relation2production($;$) { local $_=$_[0];
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
   my $rel=$relation{lc($name)};
   return if not defined $rel;
   return relation2production($rel,$name);
}
sub getallproductions()
{
   my @p=();
   foreach my $name (keys %relation) {
      my($rel)=$relation{$name};
      if(!$rel) {next}
      my($prod,undef,undef,$arti,undef,$ad,$pp,$bonus)=relation2production($rel);
      if(!defined($prod)) {next}
      my @sci=relation2science($rel);
      if($sci[0]<time()-2*24*3600) {next}
      push(@p, [$name,$prod,$ad,$pp,$bonus,$arti]);
   }
   return @p;
}

# input: artifact name (BM1)
# output: number (e.g. 3851.28 A$)
sub getartifactprice($)
{
   my($arti)=@_;
   my $p=$awinput::prices{lc($arti)}||0;
   return $p;
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

sub gettradepartners($$) { my($maxta,$minad)=@_;
  my @result;
  my $adprice=$prices{pp};
  foreach my $name (keys %relation) {
    my($rel)=$relation{$name};
    if(!$rel) {next}
    my($prod,undef,undef,undef,undef,$ad,$pp,$bonus)=relation2production($rel);
    if(!defined($prod)) {next}
    my @sci=relation2science($rel);
    if($sci[0]<time()-2*24*3600) {next}
    $ad+=$pp*$adprice;
    if($ad<$minad) {next}
    my $trades=0;
    if($rel=~/trade:([^ ]*)/) {
       my $tas=$1;
       my @a=split(/,/, $tas);
       $trades=@a;
    }
    if($trades>$maxta) {next}
#print("$name : ad: $ad \n<br />");
    push(@result,[$name,$ad, $prod*$$bonus[0]*$adprice, $trades]);
  }
  return @result;
}

# this function is intended to work without init
sub playername2alli($) {my ($user)=@_;
   if(!$user) {return ""}
#   if($user eq "greenbird") {return ""}
   my %alliuser;
   awinput::opendb(O_RDONLY, "$awstandard::dbmdir/useralli.dbm", \%alliuser);
   my $alli=$alliuser{lc $user};
   untie(%alliuser);
   if(!$alli) {
#      local $ENV{REMOTE_USER};
      tie %alliances, "MLDBM", "$dbdir/alliances.mldbm", O_RDONLY, 0666;
      tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDONLY, 0666;
#      tie %playerid, "MLDBM", "$dbdir/playerid.mldbm", O_RDONLY, 0666;
      my $pid=playername2idm($user);
#      if($user eq "greenbird") {$pid=68061}
      if($pid && $pid>2) {
         $alli=lc(playerid2tag($pid));
         if($awaccess::remap_alli{$alli}) { $alli=$awaccess::remap_alli{$alli} }
         if(!$allowedalli{$alli}) {$alli=""}
      }
   }
   return $alli;
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
   foreach my $xpid (@$otherpids) {
      my $pid1=awmax($xpid,$ownpid);
      my $pid2=awmin($xpid,$ownpid);
      #next if($oldmap{"$pid1,$pid2"}); # do not re-add existing entries
      # pid1 is always larger than pid2
      my $result=$sth->execute($pid1, $pid2, $now);
   }
}


our $fleetscreen="uninitialized";
# prepare DB for adding planet/planning info
# input: screen = integer identifying source of data (1=system-info, 2=cleanplanning)
sub dbplanetaddinit(;$) { my($screen)=@_;
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
}
# prepare DBs for adding new fleets
# input pid = player ID of whose fleets are viewed
# input screen = 0=news, 1=fleets 2=alliance_incomings 3=alliance_detail 4=alliance_detail_incoming 8=planet_detail
sub dbfleetaddinit($;$) { my($pid,$screen)=@_; $screen||=0;
   $awinput::fleetscreen=$screen;
   return unless $ENV{REMOTE_USER};
#   awdiag("name:$::options{name} scr:$screen awscr:$awinput::fleetscreen");
#	untie %planetinfo;
#	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
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
         my $sidpid=sidpid22sidpid3($sid,$pid);
         untie %planetinfo;
         opendb(O_RDWR, $dbnamep, \%planetinfo);
         my $d=AWisodate(time());
         if($time) { # moving fleet: planned to targeted
            $planetinfo{$sidpid}=~s/^2 $plid /3 $plid l:$d /;
         } else { # resting fleet: targeted to sieged
            my $newstat=($type==0?4:5); # or to taken if fleet is on own planet
            my $oldstat=($type==0?3:qr([34]));
            my $text=($type==0?"s":"took").":";
            $planetinfo{$sidpid}=~s/^$oldstat $plid /$newstat $plid $text$d /;
         }
         untie %planetinfo;
         opendb(O_RDONLY, $dbnamep, \%planetinfo);
      }
   }
   return 0;
}
sub dbfleetaddfinish() {
#	untie %planetinfo;
#	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
}

sub dbplayeriradd($;@@@@@) { my($name,$sci,$race,$newlogin,$trade,$prod)=@_;
   return if(!$ENV{REMOTE_USER});
	$name="\L$name";
	untie %relation;
	untie %planetinfo;
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
	my $oldentry=$relation{$name};
	my $newentry=addplayerir($oldentry, $sci,$race,$newlogin,$trade,$prod);
	if($newentry) {
		if(!$::options{debug}) {$relation{$name}=$newentry;}
		else {print "<br />$name new:",$newentry;}
	}
	untie %relation;
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
}

sub dblinkadd { my($sid,$url)=@_;
   my $type;
   if($url=~m!http://forum\.rebelstudentalliance\.co\.uk/index\.php\?showtopic=(\d+)!) { $type="RSA" } # IPB
   elsif($url=~m!http://flebb\.servebeer\.com/sknights/index\.php\?showtopic=(\d+)!) { $type="SK" } # IPB
   elsif($url=~m!http://z10.invisionfree.com/Trolls/index.php\?showtopic=(\d+)!) { $type="TROL" } # IPB
   elsif($url=~m!http://s6.invisionfree.com/LOVE/index.php\?showtopic=(\d+)!) { $type="LOVE" } # IPB
#   elsif($url=~m!http://xtasisrebellion\.free\.fr/phpnuke/modules\.php\?name=Forums&file=viewtopic&t=(\d+)!) { $type="XR" } # hacked and outdated
   elsif($url=~m!http://xtasisrebellion\.xt\.ohost\.de/forum/index\.php\?topic=([0-9.]+)!) { $type="XR" } # SMF
   elsif($url=~m!http://www.anacronic.com/FIR/index.php\?topic=([0-9.]+)!) { $type="FIR" } # SMF
   elsif($url=~m!http://frozenstar.zoreille.info/index.php\?topic=([0-9.]+)!) { $type="FrS" } # SMF
   elsif($url=~m!http://www.aw-oceans11.de/smf/index.php\?topic=([0-9.]+)!) { $type="OXI" } # SMF
   elsif($url=~m!http://www.apgaming.com/index.php\?[a-zA-Z0-9&=_]topic=([0-9.]+)!) { $type="APG" } # SMF mod?
#   elsif($url=~m!http://lesnains\.darkbb\.com/viewtopic\.forum\?[pt]=(\d+)!) { $type="NAIN" } # phpBB outdated
   elsif($url=~m!http://lesnains\.darkbb\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="NAIN" } # some custom phpBB mod?
   elsif($url=~m!http://spin.forumzen.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="SpIn" } # some custom phpBB mod?
   elsif($url=~m!http://en\.forumactif\.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="EN" } # some custom phpBB mod?
   elsif($url=~m!http://alien.forum2jeux.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="AN" } # some custom phpBB mod?
   elsif($url=~m!http://mtg-aw.forumzen.com/[a-z0-9/-]+/[0-9a-z-]+-[pt](\d+)\.htm!i) { $type="MtG" } # some custom phpBB mod?
   elsif($url=~m!http://quicheinside\.free\.fr/viewtopic\.php\?[pt]=(\d+)!) { $type="QI" } # phpBB
   elsif($url=~m!http://(?:www\.)vbbyjc\.com/phpBB2/viewtopic\.php\?[pt]=(\d+)!) { $type="SW" } # phpBB
   elsif($url=~m!http://allianceffa.free.fr/ZeForum/viewtopic\.php\?[pt]=(\d+)!) { $type="FFA" } # phpBB
   elsif($url=~m!http://www.ionstorm-alliance.com/forum/viewtopic\.php\?[pt]=(\d+)!) { $type="IS" } # phpBB
   elsif($url=~m!http://www.createforum.com/punx/viewtopic\.php\?[pt]=(\d+)!) { $type="PUNX" } # phpBB
   elsif($url=~m!http://holi87.webd.pl/forum/viewtopic\.php\?[pt]=(\d+)!) { $type="SoUP" } # phpBB
   elsif($url=~m!http://www.awocb.com/viewtopic\.php\?[pt]=(\d+)!) { $type="OCB" } # phpBB
   elsif($url=~m!http://87\.106\.97\.15/forum/blacksheep/viewtopic\.php\?[pt]=(\d+)!) { $type="BLA" } # phpBB
   elsif($url=~m!http://she.m-30.net/viewtopic\.php\?[pt]=(\d+)!) { $type="SHE" } # phpBB
   elsif($url=~m!http://lordvic.free.fr/ForumADN/viewtopic\.php\?[pt]=(\d+)!) { $type="ADN" } # phpBB
   elsif($url=~m!http://www.ouebomatik.net/forums/viewtopic\.php\?[pt]=(\d+)!) { $type="CPO" } # phpBB
   elsif($url=~m!http://whfoundation.7.forumer.com/viewtopic\.php\?[pt]=(\d+)!) { $type="WHF" } # phpBB
   elsif($url=~m!http://council.14.forumer.com/viewtopic\.php\?[pt]=(\d+)!) { $type="CoRE" } # phpBB
   elsif($url=~m!http://lba-lbb.iespana.es/viewtopic\.php\?[pt]=(\d+)!) { $type="LBA" } # phpBB
   elsif($url=~m!http://www\.astrowars\.com/forums/viewtopic\.php\?[pt]=(\d+)!) { $type="main AW" } # phpBB
   elsif($url=~m!http://www.fishandreef.com/brigada/modules.php\?(?:name=Forums&)?(?:file=viewtopic&)?t=(\d+)!) { $type="LBA" } # Version 2.0.7 by Nuke Cops
   return unless($sid && $type);
   $url=$&;
   my $sidpid=sidpid22sidpid3($sid,0);
   my $oldentry=$planetinfo{$sidpid};
   return if($oldentry);
   $planetinfo{$sidpid}=qq(0 0 see also <a href="$url">this $type forum thread</a>);
}

sub playername2ir($) { my($name)=@_;
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
   return playername2ir(playerid2name($plid));
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
# BS: (107709/100000-1)/5 = 0.015418
   return int($cv*(1+$phys*0.01525)*(1+$awstandard::racebonus[5]*$att));
}

# input: alli
# output: SQL to match allies
sub get_alli_match($;$)
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

sub get_team_pids($)
{
   my($team)=@_;
   if(!$ENV{REMOTE_USER}) {return []}
   my $m="";
   if($team) {
      $m="AND ".awinput::get_alli_match($ENV{REMOTE_USER},'tag');
   } else {
      $m="AND `tag` = '$ENV{REMOTE_USER}'";
   }
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT `pid` FROM alliances,player WHERE aid = alliance $m");
#   my $res=$dbh->selectall_arrayref("SELECT DISTINCT usersession.pid FROM usersession,alliances,player WHERE usersession.pid = player.pid AND aid = alliance AND $m");
   my $res=$dbh->selectall_arrayref($sth, {});
   return $res;
}

sub get_all_brownie_pids
{
   my $dbh=get_dbh;
   my $res=$dbh->selectall_arrayref("SELECT pid FROM usersession GROUP BY usersession.pid");
}

# get all fleets visible to own alli
# input: SQL condition to add - defaults to ""
sub get_fleets2($) { my($cond)=@_;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   $cond||="";
   my $allimatch=get_alli_match($alli);
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT * from `fleets` WHERE ($allimatch) $cond");
   my $res=$dbh->selectall_arrayref($sth, {});
   return $res;
}

# input: sidpid
# input: SQL condition to add - defaults to ""
sub get_fleets($;$) { my($sidpid,$cond)=@_;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   $cond||="";
   my $allimatch=get_alli_match($alli);
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT * from `fleets` WHERE ($allimatch) AND `sidpid` = ? $cond ORDER BY `eta` ASC, `lastseen` ASC");# AND `iscurrent` = 1");
   my $res=$dbh->selectall_arrayref($sth, {}, $sidpid);
   return $res;
}

sub get_fleet($) {
   my $fid=shift;
   my $alli=$ENV{REMOTE_USER};
   if(!$alli) {return [];}
   my $dbh=get_dbh;
   my $allimatch=get_alli_match($alli);
   my $sth=$dbh->prepare("SELECT * from `fleets` WHERE `fid` = ? AND ($allimatch)");
   my $res=$dbh->selectall_arrayref($sth, {}, $fid);
   return $res;
}

our %fleetcolormap=(1=>"#777", 2=>"#d00", 3=>"#f77");
# input: 1 row from fleet table
# output: HTML for a short display of fleet with detailed info in title=
sub show_fleet($) { my($f)=@_;
   my $minlen=21;
   my $minlen1=34;
   #fid alli status sidpid owner eta firstseen lastseen trn cls ds cs bs cv xcv iscurrent info
   my($fid, $sidpid, $owner, $eta, $firstseen, $lastseen, $trn, $cls, $cv, $xcv, $iscurrent, $info)=@$f[0,3..9,13..16];
   if($cv==0 && $cls==0 && $trn==0) {return ""}
   my $color=!$iscurrent;
   my $tz=$timezone*3600;
   my $flstr="$cv/$xcv CV";
   if($trn){$flstr.=", $trn TRN"; if($eta){$color|=2;}}
   if($cls){$flstr.=", $cls CLS";}
   if($color) {$color="; color:$fleetcolormap{$color}"}
   if(!$eta && $iscurrent){$color.="; text-decoration:underline"}
   my $tz2=($timezone>=0?"+":"").$timezone;
   if($eta) {$eta=AWisodatetime($eta+$tz)." GMT$tz2 ".awstandard::AWreltime($eta)} else {$eta="defending fleet.............."}
   if(length($eta)<$minlen1) {$eta.="&nbsp;" x ($minlen1-length($eta))}
   if(length($flstr)<$minlen) {$flstr.="&nbsp;" x ($minlen-length($flstr))}
   my $sid=sidpid2sidm($sidpid);
   my $pid=sidpid2pidm($sidpid);
   my $xinfo="$sid#$pid".": fleet=@$f[8..12] firstseen=".awstandard::AWreltime($firstseen)." lastseen=".awstandard::AWreltime($lastseen);
   if($info) {$info=" ".$info}
   return "<span style=\"font-family:monospace $color\" title=\"$xinfo\"><a href=\"${toolscgiurl}edit-fleet?fid=$fid\">edit</a> <a href=\"${toolscgiurl}fleetbattlecalc?fid=$fid\">bc</a> <a href=\"${toolscgiurl}whocanintercept?p=$sid%23$pid&amp;cvlimit=$cv\">catch</a> $eta $flstr ".playerid2link($owner).$info."</span>";
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
   a({-href=>"alliance?alliance=$atag&omit=9+12+15"},$atag);
}
sub display_sid($) { my($sid)=@_;
   my ($x,$y)=systemid2coord($sid);
   a({-href=>"system-info?id=$sid"},"$sid($x,$y)");
}
sub display_sid2($) { my($sid)=@_;
   my $name=systemid2name($sid);
   return "" if ! $name;
   my ($x,$y)=systemid2coord($sid);
   return a({-href=>"http://$bmwserver/cgi-bin/system-info?id=$sid"},"$name ($x,$y)");
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
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("SELECT * from `playerprefs` WHERE `pid` = ?");
   my $res=$dbh->selectall_arrayref($sth, {}, $pid);
   if($res) {return $res->[0]}
   return $res;
}

1;
