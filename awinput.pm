#!/usr/bin/perl -w
package awinput;
use strict "vars";
require 5.002;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
our (%alliances,%starmap,%player,%playerid,%planets,%battles,%trade,%relation,%planetinfo,
   $dbnamer,$dbnamep);
our $adprice=0.93;
our $alarmtime=99;
our $dbdir="/home/aw/db/db";

$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = qw(
&awinput_init &getrelation &setrelation &playername2id &playerid2name &playerid2home &playerid2country &getplanet &playerid2link &getplanetinfo &setplanetinfo &systemname2id &systemcoord2id &systemid2name &systemid2level &systemid2coord &systemid2planets &allianceid2tag &allianceid2members &alliancetag2id &playerid2alliance &playerid2planets &playerid2tag &planet2sb &planet2pop &planet2opop &planet2owner &planet2siege &planet2pid &planet2sid &getatag &sidpid2planet &getplanet2 &sidpid22sidpid3 &sidpid22sidpid3m &gettradepartners &dbfleetaddinit &dbfleetadd &dbfleetaddfinish &dbplayeriradd &dblinkadd
&display_pid &display_relation &display_sid &display_sid2 &sort_pid
%alliances %starmap %player %playerid %planets %battles %trade %relation %planetinfo
);


use MLDBM qw(DB_File Storable);
#use DBAccess;
use DB_File::Lock;
use CGI ":standard";
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY);
use awaccess;
use awstandard;
my $head="Content-type: text/plain\015\012";

sub awinput_init(;$) { my($nolock)=@_;
   awstandard_init();
#chdir "/home/aw/db"; # done by awstandard_init
   tie %alliances, "MLDBM", "db/alliances.mldbm", O_RDONLY, 0666 or die $!;
   tie %starmap, "MLDBM", "db/starmap.mldbm", O_RDONLY, 0666;
   tie %player, "MLDBM", "db/player.mldbm", O_RDONLY, 0666;
   tie %playerid, "MLDBM", "db/playerid.mldbm", O_RDONLY, 0666;
   tie %planets, "MLDBM", "db/planets.mldbm", O_RDONLY, 0666;
   tie %battles, "MLDBM", "db/battles.mldbm", O_RDONLY, 0666;
   tie %trade, "MLDBM", "db/trade.mldbm", O_RDONLY, 0666;
   if($ENV{REMOTE_USER}) {
      $dbnamer="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
      $dbnamep="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
#     if($ENV{REMOTE_USER} ne "guest") {
      alarm($alarmtime); # make sure locks are free'd
      if($nolock) {
         tie(%relation, "DB_File", $dbnamer, O_RDONLY, 0, $DB_HASH);
         tie(%planetinfo, "DB_File", $dbnamep, O_RDONLY, 0, $DB_HASH);
      } else {
         tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
         tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
      }
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
		my $id=playername2id($name);
		if(!$id) {
			if($hadentry){last}
			return undef
		}
		my $aid=$player{$id}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel) {$atag=$ally;$aid=-1;}
		if(!$aid) { return undef }
		if($aid>0) {$ally=$atag=$alliances{$aid}{tag};}
#		print "id $id a $aid at $atag\n<br>";
		my $rel2=$relation{"\L$atag"};
		if($rel2) { 
			$rel2=~/^(\d+) (\w+) /s;
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

sub playerid2link($) { my($id)=@_;
   if($id==0) {return "free planet"}
   my $name=playerid2name($id);
   my @rel=getrelation($name);
   my $col=getrelationcolor($rel[0]);
   my $alli="";
   my $atag=playerid2tag($id);
   if($atag) {$alli="[$atag] "}
   elsif($rel[1]) {$alli="[$rel[1]] "}
   return a({-href=>"relations?id=$id", -style=>"color:$col"}, "$alli$name");
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
	#print "set '$id', '$options' $dbnamep ";
	if(!$options) {delete $planetinfo{$id}; }
	else {
		$planetinfo{$id}="$$options{status} $$options{who} $$options{info}";
	}
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
}
sub systemname2id($) { my($name)=@_;
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
	$alliances{$id}?$alliances{$id}{tag}:undef;
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
sub sidpid22sidpid3m($$) {return $_[0]*13+$_[1];}

sub gettradepartners($$) { my($maxta,$minad)=@_;
  my @result;
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
    push(@result,[$name,$ad, $prod*$$bonus[0], $trades]);
  }
  return @result;
}

sub playername2alli($) {my ($user)=@_;
   my %alliuser;
   awinput::opendb(O_RDONLY, "/home/aw/db2/useralli.dbm", \%alliuser);
   my $alli=$alliuser{lc $user};
   untie(%alliuser);
   if(!$alli) {
      local $ENV{REMOTE_USER};
      tie %alliances, "MLDBM", "$dbdir/alliances.mldbm", O_RDONLY, 0666;
      tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDONLY, 0666;
      tie %playerid, "MLDBM", "$dbdir/playerid.mldbm", O_RDONLY, 0666;
      my $pid=playername2id($user);
      if($pid && $pid>2) {
         my $aid=playerid2alliance($pid);
         $alli=lc(playerid2tag($pid));
         if($awaccess::remap_alli{$alli}) { $alli=$awaccess::remap_alli{$alli} }
         if(!$allowedalli{$alli}) {$alli=""}
      }
   }
   return $alli;
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
# input screen = 0=news, 1=fleets 2=alliance_incomings 3=alliance_detail
sub dbfleetaddinit($;$) { my($pid,$screen)=@_; $screen||=0;
   $awinput::fleetscreen=$screen;
#   awdiag("name:$::options{name} scr:$screen awscr:$awinput::fleetscreen");
#	untie %planetinfo;
#	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
   require DBAccess;
   if($pid) {
      my $cond="";
      if($screen==1) {$cond=" AND ( `trn` != 0 OR `cls` != 0 OR `ds` != 0 OR `cs` != 0 OR `bs` != 0 ) "}
      my $sth=$DBAccess::dbh->prepare_cached("UPDATE `fleets` SET `iscurrent` = 0 WHERE `alli` = ? AND `owner` = ? $cond");
      $sth->execute($ENV{REMOTE_USER}, $pid);
   } 
}
sub dbfleetadd($$$$$$@;$) { my($sid,$pid,$plid,$name,$time,$type,$fleet,$tz)=@_;
   if(! defined($tz)) {$tz=$::options{tz}}
   if($time) {$time-=3600*$tz}
   {
#      local $^W=0;
      require "fleetadd.pm"; fleetadd::dbfleetaddmysql($sid,$pid,$plid,$name,$time,$type,$fleet,$tz);
   }
   return 0;
	my $sidpid=sidpid22sidpid3($sid,$pid);
	my $oldentry=$planetinfo{$sidpid};
	my $newentry=addfleet($oldentry,$plid, $name, $time, $type, $fleet);
	if($newentry) {
		if(!$::options{debug}) {
         $planetinfo{$sidpid}=$newentry;
         return !$oldentry || $newentry ne $oldentry;
      }
		else {print "$sid#$pid: $newentry <br />\n"}
	}
   return 0;
}
sub dbfleetaddfinish() {
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
}

sub dbplayeriradd($;@@@@@) { my($name,$sci,$race,$newlogin,$trade,$prod)=@_;
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
   if($url=~m!http://xtasisrebellion.free.fr/phpnuke/modules.php\?name=Forums&file=viewtopic&t=(\d+)!) { $type="XR" }
   elsif($url=~m!http://forum.rebelstudentalliance.co.uk/index.php\?showtopic=(\d+)!) { $type="RSA" }
   elsif($url=~m!http://(?:www.)vbbyjc.com/phpBB2/viewtopic.php\?t=(\d+)!) { $type="SW" }
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

sub estimate_xcv($$) { my($plid,$cv)=@_;
   return $cv if(!$plid || $plid<=2 || !defined($player{$plid}));
   my ($phys,$att)=($player{$plid}{sl}, +4);
   my ($race,$sci)=playerid2ir($plid);
   if($race) { # use phys+race or SL+4
      $att=$$race[5];
   }
   if($sci && $$sci[0]>time()-4*24*3600) {
      $phys=$$sci[5];
   }
# phys adj values: 
# DS: (107518/100000-1)/5 = 0.015036 ... 0.01525 ?
# CS: (211633/1.25/100000-1)/40 = 0.0173266
# BS: (107709/100000-1)/5 = 0.015418
   return int($cv*(1+$phys*0.01525)*(1+$awstandard::racebonus[5]*$att));
}

# input: sidpid
# input: SQL condition to add - defaults to ""
sub get_fleets($;$) { my($sidpid,$cond)=@_;
   $cond||="";
   my $sth=$DBAccess::dbh->prepare_cached("SELECT * from `fleets` WHERE `alli` = ? AND `sidpid` = ? $cond ORDER BY `eta` ASC, `lastseen` ASC");# AND `iscurrent` = 1");
   my $res=$DBAccess::dbh->selectall_arrayref($sth, {}, $ENV{REMOTE_USER}, $sidpid);
   return $res;
}

our %fleetcolormap=(1=>"#777", 2=>"#d00", 3=>"#f77");
# input: 1 row from fleet table
# output: HTML for a short display of fleet with detailed info in title=
sub show_fleet($) { my($f)=@_;
   my $minlen=21;
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
   if($eta) {$eta=AWisodatetime($eta+$tz)} else {$eta=" defending fleet.... "}
   if(length($flstr)<$minlen) {$flstr.="&nbsp;" x ($minlen-length($flstr))}
   my $xinfo=sidpid2sidm($sidpid)."#".sidpid2pidm($sidpid).": fleet=@$f[8..12] firstseen=".AWisodatetime($firstseen+$tz)." lastseen=".AWisodatetime($lastseen+$tz);
   if($info) {$info=" ".$info}
   return "<span style=\"font-family:monospace $color\" title=\"$xinfo\"><a href=\"http://aw.lsmod.de/cgi-bin/edit-fleet?fid=$fid\">edit</a> $eta $flstr ".playerid2link($owner)."$info</span>";
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

1;
