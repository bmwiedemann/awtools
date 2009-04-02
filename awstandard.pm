package awstandard;

use strict;
require 5.002;
use constant DAYSECS => 3600*24;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = 
qw(&awstandard_init &bmwround &bmwmod &awdiag &AWheader3 &AWheader2 &AWheader &AWtail &AWfocus &wikilink getawwwwserver
&mon2id &parseawdate &getrelationclass &getrelationcolor &getstatuscolor &planetlink &profilelink &alliancedetailslink &systemlink &alliancelink &addplayerir &fleet2cv &addfleet &relation2race &relation2science &gmdate &AWtime &AWisodate &AWisodatetime &AWreltime &sb2cv &title2pm &safe_encode &html_encode &file_content &url2pm &awmax &awmin &getauthpid &getparsed
      $magicstring $style $server $awserver $bmwserver $toolscgiurl $timezone %planetstatusstring %relationname $interbeta $basedir $dbdir @racebonus %artifact);

use CGI ":standard";
use Time::Local;
use Time::HiRes qw(gettimeofday tv_interval);

our $server="www1.astrowars.com";       # AW game host
our $awserver="www1.astrowars.com";     # proxied AW game host
our $awforumserver="www.astrowars.com"; # AW forum host
our $bmwserver="aw.lsmod.de";           # the domain name you use for the AWTools
our $proxyip="192.168.236.1";
our $toolscgiurl="";#"http://$bmwserver/cgi-bin/";
our $basedir;
our $dbmdir; 
BEGIN{
   $basedir="/home/aw";
   $dbmdir="$basedir/db2";
}
our $dbdir="$basedir/db/db";
our $codedir="$basedir/inc";
our $htmldir="$basedir/html";
our $cssdir="$basedir/css";
our $allidir="$basedir/alli";
our $interbeta=0;
our $style;
our $timezone;
our $updatetime15=16*60;
our @month=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our %month=qw(Jan 1 Feb 2 Mar 3 Apr 4 May 5 Jun 6 Jul 7 Aug 8 Sep 9 Oct 10 Nov 11 Dec 12);
our @weekday=qw(Sun Mon Tue Wed Thu Fri Sat);
our %relationname=(0=>"from alliance", 1=>"total war", 2=>"foe", 3=>"tense", 4=>"unknown(neutral)", 5=>"implicit neutral", 6=>"NAP", 7=>"friend", 8=>"ally", 9=>"member");
our %planetstatusstring=(1=>"unknown", 2=>"planned by", 3=>"targeted by", 4=>"sieged by", 5=>"taken by", 6=>"lost to", 7=>"defended by");
our @sciencestr=(qw(Biology Economy Energy Mathematics Physics Social),"Trade Revenue");
our @racestr=qw(growth science culture production speed attack defense);
our @shipstr=qw(Transports Colony Destroyer Cruiser Battleship);
our @buildingstr=qw(HF RF GC RL SB TRN CLS DS CS BS);
our @buildingval=qw(farm fabrik kultur forschungslabor starbase infantrieschiff kolonieschiff destroyer cruiser battleship);
our @racebonus=qw(0.07 0.08 0.05 0.04 0.01 0.12 0.16);
our $magicstring="automagic:";
our %artifact=(""=>0, "BM"=>4, "AL"=>2, "CP"=>1, "CR"=>5, "CD"=>8, "MJ"=>10, "HoR"=>15);
our @relationcolor=("", "firebrick", "OrangeRed", "orange", "grey", "navy", "RoyalBlue", "darkturquoise", "LimeGreen", "green");
our @relationclass=("neutral", "totalwar", "foe", "tense", "neutral", "ineutral", "nap", "friend", "ally", "member");
our @statuscolor=qw(black black blue cyan red green orange green);
our $start_time;
our $customhtml;

require awaccess; # needs 1 var
use DBAccess2;

sub awstandard_init() {
   my $alli=$ENV{REMOTE_USER};
   if($alli && $awaccess::remap_alli{$alli}) {
      $ENV{REMOTE_USER}=$alli=$awaccess::remap_alli{$alli};
   }
#   chdir $codedir;
   $style=cookie('style');
   $timezone=cookie('tz');
   $customhtml=cookie('customhtml');
   $toolscgiurl="";
   if((my $pid=getauthpid())) {
      my $dbh=get_dbh;
      my $sth=$dbh->prepare_cached("SELECT `tz`,`customhtml`,`awtoolsstyle` FROM `playerprefs` WHERE `pid` = ?");
      my $res=$dbh->selectall_arrayref($sth, {}, $pid);
      if($res && $res->[0]) {
         my($tz,$ch,$awtstyle)=@{$res->[0]};
         if(defined($tz)) {
            $timezone=$tz;
         }
         if(defined($ch)) {
            $customhtml.=$ch;
         }
			if($awtstyle) {$style=$awtstyle}
      }
		$awserver="aw21.zq1.de";
      my ($proxy)=get_one_row("SELECT `proxy` FROM `usersession` WHERE `pid` = ? ORDER BY `lastclick` DESC LIMIT 1", [$pid]);
		if($proxy) { $awserver=$proxy; }
   }
   if(!defined($timezone)) {$timezone=0}
   $start_time=[gettimeofday()];
}
# free locks & other critical resources
sub awstandard_finish() {
}

sub getawwwwserver() {
	if($awserver=~m/^aw21/) {
		return "www.$awserver";
	}
	return $awforumserver;
}

sub bmwround($) { my($number)=@_;
   return int($number + .5 * ($number <=> 0));
}
sub bmwmod($$) { my($number,$mod)=@_; my $sign=($number <=> 0);
   my $off=50;
   return ((($number*$sign + $off)%$mod - $off) *$sign );
}

sub awdiag($) { my ($str)=@_;
   open(LOG, ">>", "/tmp/aw.log");
   print LOG (scalar localtime()." $str\n");
   close(LOG);
}

sub AWheader3($$;$) { my($title, $title2, $extra)=@_;
	my $links="";
	my $owncgi=$ENV{SCRIPT_NAME}||"";
   my $heads=[Link({-rel=>"icon", -href=>"/favicon.ico", -type=>"image/ico"}),Link({-rel=>"shortcut icon", -href=>"http://aw.lsmod.de/favicon.ico"})];
   if($extra) {push(@$heads,$extra);}
   push(@$heads,qq!<link rel="stylesheet" type="text/css" href="/code/css/tools/common.css" />!);
#   push(@$heads, "<title>$title</title>");
	$owncgi=~s!/cgi-bin/(?:modperl/)?!!;
	foreach my $item (qw(index.html tactical-live tactical-live2 relations allirelations alliance system-info fleets)) {
		my %h=(href=>$item);
		if($item eq $owncgi) {
			$h{class}='headeractive';
			$links.="|".span({-class=>"headeractive"},"&nbsp;".a(\%h,$item)." ");
			next;
		}
		$links.="|&nbsp;".a(\%h,$item)." ";
	}
	if($ENV{HTTP_AWPID}) {
		$links.="|&nbsp;".a({-href=>"relations?id=$ENV{HTTP_AWPID}"}, "self");
	}
	$links.=$customhtml||"";
	if(!$style) {$style='blue'}
   my $flag = autoEscape(0);
	local $^W=0; #disable warnings for next line
   my $retval=start_html(-title=>$title, -style=>"/code/css/tools/$style.css", 
	# -head=>qq!<link rel="icon" href="/favicon.ico" type="image/ico" />!).
	 -head=>$heads);
   autoEscape([$flag]);
   my $imsg="";
   use awimessage;
   my $pid=getauthpid();
   if($pid && (my $imsgcount=awimessage::get_recv_count($pid))) {
      $imsg.=div({-class=>"awimessage"}, ("You have received $imsgcount ".a({-href=>"imessage"},"BIM".($imsgcount>1?"s":""))));
   }
	return $retval.
#      img({-src=>"/images/greenbird_banner.png", -id=>"headlogo"}).
      div({-align=>'justify',-class=>'header'},
#a({href=>"index.html"}, "AW tools index").
	$links).
   "\n$imsg".a({-href=>"?"},h1($title2))."\n";
}
sub AWheader2($;$) { my($title,$extra)=@_; AWheader3($title, $title, $extra);}
sub AWheader($;$) { my($title,$extra)=@_; header(-connection=>"Keep-Alive", -keep_alive=>"timeout=15, max=99").AWheader2($title,$extra);}
sub AWtail() {
   eval "awinput::awinput_finish()";
	my $t = sprintf("%.3f",tv_interval($start_time));
	return hr()."request took $t seconds".end_html();
}
sub AWfocus($) { my($elem)=@_;
    return
   qq'<script language="javascript" type="text/javascript">
     document.$elem.focus();
     document.$elem.select();
   </script>';
}

sub wikilink($)
{ my($name)=@_;
	return a({-href=>"http://wiki.zq1.de/wiki/$name"}, $name);
}


sub mon2id($) {my($m)=@_;
#        for(my $i=0; $i<12; $i++) {
#                if($m eq $month[$i]) {return $i}
#        }
        return $month{$m}-1;
}

# input: AW style time string
# output: UNIX timestamp
sub parseawdate($) {my($d)=@_;
        my @val;
        if(my @v=($d=~/(\d\d):(\d\d):(\d\d)\s-\s(\w{3})\s(\d+)/)) {
           @val=@v;
        } elsif(@v=($d=~/(\w{3})\s(\d+)\s-\s(\d\d):(\d\d):(\d\d)/)) {
           @val=@v[2,3,4,0,1];
        } else { return undef }
#if($d!~/(\d\d):(\d\d):(\d\d)\s-\s(\w{3})\s(\d+)/);
        my ($curmon,$year)=(gmtime())[4,5];
        my $mon=mon2id($val[3]);
        if($mon<$curmon-6){$year++}
        if($mon>$curmon+6){$year--}
        return timegm($val[2],$val[1],$val[0],$val[4], $mon, $year);
}

sub getrelationclass($) { my($rel)=@_;
   if(!$rel) { return "bmwrunknown" }
   return "bmwr".$relationclass[$rel];
}
sub getrelationcolor($) { my($rel)=@_;
        if(!$rel) { $rel=4; }
        $relationcolor[$rel];
}

sub getstatuscolor($) { my($s)=@_; if(!$s) {$s=1}
        $statuscolor[$s];
}
# http://www.iconbazaar.com/color_tables/lepihce.html

sub planetstatus($) {my($status)=@_;
   return "<span style=\"color:$statuscolor[$status]\">$planetstatusstring{$status}</span>";
}
sub planetlink($) {my ($id)=@_;
        my $escaped=$id;
        $escaped=~s/#/%23/;
        return qq!<a href="planet-info?id=$escaped">$id</a>!;
}
sub profilelink($) { my($id)=@_;
        qq!<a class="aw" href="http://$awserver/about/playerprofile.php?id=$id"><img src="/images/aw/profile1.gif" title="public" alt="public profile" /></a> <a class="aw" href="http://$awserver/0/Player/Profile.php/?id=$id"><img src="/images/aw/profile2.gif" alt="personal profile" /></a>\n!;
}
sub alliancedetailslink($) { my($id)=@_;
        qq!<a class="aw" href="http://$awserver/0/Alliance/Detail.php/?id=$id"><img src="/images/aw/profile3.gif" alt="member details" /></a>\n!;
}
sub systemlink($;$) { my($id,$pid)=@_;
	my $extra="";
	if($pid){$extra="&amp;target=$pid"}
        qq!<a href="system-info?id=$id$extra">info for system $id</a>\n!;
}

sub alliancelink($) { my($atag)=@_;
   a({-href=>"alliance?alliance=$atag&omit=10+13+16"},"[$atag]");
}


sub addplayerir($@@;$@@) { my($oldentry,$sci,$race,$newlogin,undef,$prod)=@_;
	foreach($race,$sci) {next unless defined $_; if(!@$_){$_=undef}}
	if($race) {$race="race:".join(",",@$race);} else {undef $race}
	if($sci) {
      my @oldsci=relation2science($oldentry);
      if($oldsci[0] && $oldsci[0]>100) {shift @oldsci}
      for my $i(0..7) { $oldsci[$i]=$$sci[$i] if defined($$sci[$i]);}
      $sci="science:".time().",".join(",",@oldsci);
   } else {undef $sci}
#	if($trade) {$trade="trade:".join(",",@$trade);} else {undef $trade}
	if($prod) {$prod="production:".join(",",@$prod);} else {undef $prod}
	if(!$oldentry) {$oldentry="0 UNKNOWN "}
	my ($rest,$magic)=($oldentry,$magicstring." ");
	if($oldentry=~/^(\d+ \w+ .*)(?=$magicstring)(.*)/s){
		($rest,$magic)=($1,$2);
	}
#	if(!$magic) {$magic=$magicstring." "}
#	if($trade && $magic!~s/trade:\S*/$trade/) {$magic=~s/automagic:/$&\n$trade /}
	if($prod && $magic!~s/production:\S*/$prod/) {$magic=~s/automagic:/$&\n$prod /}
	if($sci && $magic!~s/science:[-+,.0-9?]*/$sci/) {$magic=~s/automagic:/$&\n$sci /}
	if($race && $magic!~s/race:[-+,0-9?]*/$race/) {$magic=~s/automagic:/$&\n$race /}
	if($newlogin) {
		my @l2=@$newlogin;
		my $add=1;
      foreach my $lold (($l2[0]+1)..($l2[0]+4)) {
         $magic=~s/login:${lold}:.*//s; # erase outdated entries
      }
# login-time can not be before prev login, so reduce accuracy margin accordingly
      if(($l2[3]>=86399) && (my @l0=($magic=~/login:(\d+):(\d+):(\d+):(\d+)\s*$/))) {
         my $diff=$l2[1]-$l2[3]-($l0[1]+$l0[2]);
#         print STDERR "playerir @l2 - @l0 - $diff\n";
         if($diff<0) {$l2[3]=awmax(1, $l2[3]+$diff)}
      }
# merge old and new login data. format is:
# login-nr, login-timestamp, idle-time, accuracy-margin
# real login time must have been between time and time-margin
# no login between time and time+idle
		if($oldentry=~/login:$l2[0]:(\d+):(\d+):(\d+)/) {
         my @l1=($l2[0],$1,$2,$3);
         my @l3=@l1;
         # adjust start+idle times
         if($l2[1]<$l1[1]) {$l3[1]=$l2[1]; $l3[3]-=$l1[1]-$l2[1] }
         if($l2[1]+$l2[2] > $l1[1]+$l1[2]) {
            $l3[2]=$l2[1]+$l2[2]-$l3[1];
            my $maxerr=$l2[3]-($l2[1]-$l1[1]);
            if($maxerr>0 && $l3[3]>$maxerr) {$l3[3]=$maxerr}
         }
         if($l3[1]<$l1[1]) {
            my $tdiff=$l3[1]+$l3[2]-($l1[1]+$l1[2]);
            if($tdiff<$l3[3]) { $l3[3]=$tdiff }
         }
         
#my $diff=abs($l2[1]-$l1[1]);
#			print "debug: @l1 + @l2 -> @l3";
#			if($diff<$l2[3]) { $add=0; }
         $magic=~s/ login:$l2[0]:[^ ]*//;
         @l2=@l3;
		}
      $l2[3]=awmax(1, $l2[3]);
		$magic.=" login:".join(":",@l2) if $add;
	}
	chomp($rest);
   $rest=~s/[\n\r][\n\r]+/\n/g;
	return $rest."\n".$magic;
}

sub fleet2cv(@) { my($fleet)=@_;
	return $$fleet[2]*3+$$fleet[3]*24+$$fleet[4]*60;
}
# input time in UTC
sub addfleet($$$$$@;$) { my($oldentry,$pid, $name, $time, $own, $fleet, $tz)=@_;
	my $status=4;
	my $ships=0;
	if($own) {$status=7}
	if($own==0) {$status=4}
	if($time) {$status=3}
	else {$time=time()}
	my $gmtime=gmtime($time);
	for my $s (@$fleet) {$ships+=$s}
	my $CV=fleet2cv($fleet);
	#if($CV<10) {return $oldentry}
	if($ships<1 && $status!=4) {return $oldentry}
	if(($oldentry && $oldentry=~/@$fleet/) || $time<time()-3600*24) {return $oldentry}
	$oldentry||="$status $pid";
	return "$oldentry \nautomagic:$name:$gmtime @$fleet ${CV}CV";
}


sub relation2race($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/race:([0-9,+-]*)/);
	my @race=split(",", $1);
   my $sum=0;
   foreach my $r (@race) {$sum+=$r}
   push(@race,$sum);
   return @race;
}
sub relation2science($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/science:([0-9,.+-]*)/);
	return split(",", $1);
}

sub gmdate($) {
	my @a=gmtime($_[0]); $a[5]+=1900;
	return "$month[$a[4]] $a[3] $a[5]";
}

# input: UNIX epoch integer
# output: HTTP-conformant time string
sub HTTPdate($) {
   my ($t)=@_;
   my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday)=gmtime($t);
   $year+=1900;
   return sprintf("$weekday[$wday], %.2i $month[$mon] $year %.2i:%.2i:%.2i GMT", $mday, $hour, $min, $sec);
}

# input AW title string
# output timezone shift relative to UTC in seconds (e.g. CET=3600)
sub guesstimezone($) {my($title)=@_;
   my $utc=time();
   return undef unless $title=~m/(\d\d):(\d\d):(\d\d)/;
   my $localt=$1*3600+$2*60+$3;
   my $diff=$localt-($utc%86400);
   my $tzs=($diff+86400/2)%86400-86400/2;
   return($tzs-(($tzs+900)%(1800)-900)); # round to half hours
}

sub AWreltime($) { my($t)=@_;
   my $diff = $t-time();
   return sprintf("%.1fh %s",abs($diff)/3600,($diff>0?"from now":"ago"));
}
sub AWtime($) { my($t)=@_;
   my $tz=$timezone;
   if($tz>=0){$tz="+$tz"}
   return AWreltime($t)." = ". scalar gmtime($t)." GMT = ".scalar gmtime($t+3600*$timezone)." GMT$tz";
}

# input: UNIX timestamp
# input: ISO format date string (like 2005-12-31)
sub AWisodate($) { my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($_[0]);
   sprintf("%i-%.2i-%.2i", $year+1900, $mon+1, $mday);
}

# input: UNIX timestamp
# input: ISO format date+time string (like 2005-12-31 23:59:59)
sub AWisodatetime($) { my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($_[0]);
   sprintf("%i-%.2i-%.2i %.2i:%.2i:%.2i", $year+1900, $mon+1, $mday, $hour, $min, $sec);
}

sub sb2cv($) { my($sb)=@_;
	return int(-4+4*1.5**$sb+0.5);
}

# create a file string from a URL
sub title2pm($) { my($title)=@_;
   $title=~s/\s?Astro Wars //;
   $title=~s/ - \d+:\d+:\d+//;
   $title=~s/\?.*//;
   $title=~s/ //g;
   $title=~s/(?:\.php)?\/*$//;
   $title=~s/\//_/g;
   return lc($title);
}

sub urldecode { my($string) = @_;
# convert all '+' to ' '
   $string =~ s/\+/ /g;    
# Convert %XX from hex numbers to ASCII 
   $string =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("c",hex($1))/eg; 
   return($string);
}

# input: cookie string
sub cookie2session { my($session)=@_;
   if($session && $session=~s/^.*PHPSESSID=([a-f0-9]{32}).*/$1/) { return $session; }
   return "";
}

sub safe_encode($) { my($name)=@_;
   $name||="";
   $name=~s/[^a-zA-Z0-9-]/"_".ord($&)/ge;
   return $name;
}
my %htmlcode=(
      "<"=>"&lt;",
      ">"=>"&gt;",
      "\""=>"&quot;",
   );
sub html_encode($) {
   return if not $_[0];
   $_[0]=~s/[<>"]/$htmlcode{$&}/g;
}

sub file_content($) {my($fn)=@_;
   open(FCONTENT, "<", $fn) or return undef;
   local $/;
   my $result=<FCONTENT>;
   close(FCONTENT);
   return $result;
}
sub set_file_content($$) {my($fn,$data)=@_;
   open(my $fc, ">", $fn) or return undef;
   print $fc $data;
   close($fc);
}

sub url2pm($) {my($url)=@_;
   if(!$url){ return ();}
   $url=~s/^http:\/\///;
   $url=~s/\?.*//;
   $url=~s/\/$//;
   $url=~s/\.php//;
   $url=lc($url);
   my @result=($url);
   while($url=~s/\/[^\/]*$//) {
      push(@result, $url);
   }
   return (@result);
}

sub awmax($$) {
   $_[0]>$_[1]?$_[0]:$_[1];
}
sub awmin($$) {
   $_[0]<$_[1]?$_[0]:$_[1];
}

sub awpl2xp($) {
   5*$_[0]**2.7;
}
sub awxp2pl($) {
   ($_[0]/5)**(1/2.7)
}

sub awsyslink($;$$) {
   my($sid,$simple,$pid)=@_;
   $simple||=1;
   my $public=$ENV{REMOTE_USER}?"":"";#:"/public";
   my $and=$ENV{REMOTE_USER}?'%':'&';
   my $link=qq($public/system-info?id=$sid${and}simple=$simple${and}target=$pid">);
}

sub getauthname() {
   return $ENV{HTTP_AWUSER};
}
sub getauthpid()
{
   return $ENV{HTTP_AWPID};
}

sub isproxy($)
{
	my($ip)=@_;
	if($ip eq $awstandard::proxyip || $ip=~m/192\.168\.23[56]\.\d+/ || $ip eq "10.8.0.5" || $ip eq "85.25.150.94") {return 1}
	return 0;
}

sub map_forward_ip($)
{
	my $ip=shift;
	# directly map six in four ipv6 addrs
	$ip=~s/^2002:([0-9a-f]{2})([0-9a-f]{2}):([0-9a-f]{2})([0-9a-f]{2}):[0-9a-f:]+$/join(".", map {hex($_)} ($1,$2,$3,$4))/e; 
	if($ip=~m/^[23][0-9a-f]{3}:[0-9a-f:]+$/) {
		# map other IPv6 to 127.x.x.x
		require Digest::MD5;
		my $digest=Digest::MD5::md5($ip); # guarantees even distribution
		my @a=unpack("C*", $digest);
		$ip="127.".join(".",@a[0..2]);
	}
	return $ip
}

sub getparsed($)
{
   my $options=shift;
   require parse::dispatch;
   return parse::dispatch::dispatch($options);
}

1;
