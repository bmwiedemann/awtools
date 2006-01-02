#!/usr/bin/perl -w

use MLDBM qw(DB_File Storable);
#use DBAccess;
use DB_File::Lock;
use Fcntl qw(:flock O_RDWR O_CREAT O_RDONLY);
use strict "vars";
require "standard.pm";
my $head="Content-type: text/plain\015\012";
our (%alliances,%starmap,%player,%playerid,%planets,%battles,%trade,%relation,%planetinfo);
our $adprice=0.93;

tie %alliances, "MLDBM", "db/alliances.mldbm", O_RDONLY, 0666 or die $!;
tie %starmap, "MLDBM", "db/starmap.mldbm", O_RDONLY, 0666;
tie %player, "MLDBM", "db/player.mldbm", O_RDONLY, 0666;
tie %playerid, "MLDBM", "db/playerid.mldbm", O_RDONLY, 0666;
tie %planets, "MLDBM", "db/planets.mldbm", O_RDONLY, 0666;
tie %battles, "MLDBM", "db/battles.mldbm", O_RDONLY, 0666;
tie %trade, "MLDBM", "db/trade.mldbm", O_RDONLY, 0666;
our ($dbnamer,$dbnamep);
if($ENV{REMOTE_USER}) {
	$dbnamer="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
	$dbnamep="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
#if($ENV{REMOTE_USER} ne "guest") {
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDONLY, 0, $DB_HASH, 'read');# or print $head,"\nerror accessing DB\n";
}

sub getrelation($;$) { my($name)=@_;
	my $lname="\L$name";
	my $rel=$::relation{$lname};
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
		my $aid=$::player{$id}{alliance};
#		print "aid $aid \n";
		my $atag;
		if(!$aid && $rel) {$atag=$ally;$aid=-1;}
		if(!$aid) { return undef }
		if($aid>0) {$ally=$atag=$::alliances{$aid}{tag};}
#		print "id $id a $aid at $atag\n<br>";
		my $rel2=$::relation{"\L$atag"};
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
sub playerid2country($) { my($id)=@_;
	$::player{$id}{from};
}
sub getplanet($$) { my($sid,$pid)=@_;
	my $sys=$::planets{$sid};
	if(!$sys) {return undef}
	$$sys[$pid-1];
}

sub playerid2link($) { my($id)=@_;
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
	my $pinfo=$::planetinfo{$id};
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
	$::starmap{"\L$name"};
}
sub systemcoord2id($$) { my($x,$y)=@_;
	$::starmap{"$x,$y"};
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
        $::planets{$id}?@{$::planets{$id}}:undef;
}
sub allianceid2tag($) { my($id)=@_;
	$::alliances{$id}?$::alliances{$id}{tag}:undef;
}
sub allianceid2members($) { my($id)=@_;
        $::alliances{$id}?@{$::alliances{$id}{m}}:undef;
}
sub alliancetag2id($) { my($tag)=@_;
        $::alliances{"\L$tag"}	#?$::alliances{$id}{tag}:undef;
}
sub playerid2alliance($) { my($id)=@_;
	$::player{$id}?$::player{$id}{alliance}:undef;
}
sub playerid2planets($) { my($id)=@_;
        $::player{$id}?@{$::player{$id}{planets}}:undef;
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


sub dbfleetaddinit($) { my($pid)=@_;
	untie %planetinfo;
	tie(%planetinfo, "DB_File::Lock", $dbnamep, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
}
sub dbfleetadd($$$$$$@) { my($sid,$pid,$plid,$name,$time,$type,$fleet)=@_;
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
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDWR, 0644, $DB_HASH, 'write') or print "error accessing DB\n";
	my $oldentry=$relation{$name};
	my $newentry=addplayerir($oldentry, $sci,$race,$newlogin,$trade,$prod);
	if($newentry) {
		if(!$::options{debug}) {$relation{$name}=$newentry;}
		else {print "<br />$name new:",$newentry;}
	}
	untie %relation;
	tie(%relation, "DB_File::Lock", $dbnamer, O_RDONLY, 0644, $DB_HASH, 'read') or print "error accessing DB\n";
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

1;
