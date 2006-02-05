package awstandard;

use strict;
require 5.002;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = 
qw(&awstandard_init &bmwround &bmwmod &awdiag &AWheader3 &AWheader2 &AWheader &AWtail &AWfocus &mon2id &parseawdate &getrelationcolor &getstatuscolor &planetlink &profilelink &alliancedetailslink &systemlink &alliancelink &addplayerir &fleet2cv &addfleet &relation2race &relation2science &relation2production &gmdate &AWtime &AWisodatetime &sb2cv &title2pm &file_content
      $magicstring $style $server $bmwserver $timezone %planetstatusstring %relationname);

use CGI ":standard";
use Time::Local;
use Time::HiRes qw(gettimeofday tv_interval);

our $server="www1.astrowars.com";
our $bmwserver="aw.lsmod.de";
our $style;
our $timezone;
our @month=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our @weekday=qw(Sun Mon Tue Wed Thu Fri Sat);
our %relationname=(0=>"from alliance", 1=>"total war", 2=>"foe", 3=>"tense", 4=>"unknown(neutral)", 5=>"implicit neutral", 6=>"NAP", 7=>"friend", 8=>"ally", 9=>"member");
our %planetstatusstring=(1=>"unknown", 2=>"planned by", 3=>"targeted by", 4=>"sieged by", 5=>"taken by", 6=>"lost to", 7=>"defended by");
our @sciencestr=(qw(Biology Economy Energy Mathematics Physics Social),"Trade Revenue");
our @racestr=qw(growth science culture production speed attack defense);
our @racebonus=qw(0.07 0.08 0.04 0.04 0.19 0.15 0.16);
our $magicstring="automagic:";
our %artifact=(""=>0, "BM"=>4, "AL"=>2, "CP"=>1, "CR"=>5, "CD"=>8, "MJ"=>10, "HOR"=>15);
our @relationcolor=("", "firebrick", "OrangeRed", "orange", "grey", "navy", "RoyalBlue", "darkturquoise", "LimeGreen", "green");
our @statuscolor=qw(black black blue cyan red green orange green);
our $start_time;

sub awstandard_init() {
   chdir "/home/aw/db";
   $style=cookie('style');
   $timezone=cookie('tz');
   if(!defined($timezone)) {$timezone=0}
   $start_time=[gettimeofday()];
}
# free locks & other critical resources
sub awstandard_finish() {
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
   push(@$heads,qq!<link rel="stylesheet" type="text/css" href="/common.css" />!);
#   push(@$heads, "<title>$title</title>");
	$owncgi=~s!/cgi-bin/(?:modperl/)?!!;
	foreach my $item (qw(index.html preferences arrival tactical tactical-large tactical-live relations alliance system-info fleets feedupdate)) {
		my %h=(href=>$item);
		if($item eq $owncgi) {
			$h{class}='headeractive';
			$links.="|".span({-class=>"headeractive"},"&nbsp;".a(\%h,$item)." ");
			next;
		}
		$links.="|&nbsp;".a(\%h,$item)." ";
	}
	if(!$style) {$style='blue'}
   my $flag = autoEscape(0);
	local $^W=0; #disable warnings for next line
   my $retval=start_html(-title=>$title, -style=>"/$style.css", 
	# -head=>qq!<link rel="icon" href="/favicon.ico" type="image/ico" />!).
	 -head=>$heads);
   autoEscape([$flag]);
	return $retval.
#      img({-src=>"/images/greenbird_banner.png", -id=>"headlogo"}).
      div({-align=>'justify',-class=>'header'},
#a({href=>"index.html"}, "AW tools index").
	$links)."\n".h1($title2)."\n";
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


sub mon2id($) {my($m)=@_;
        for(my $i=0; $i<12; $i++) {
                if($m eq $month[$i]) {return $i}
        }
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
        return timegm($val[2],$val[1],$val[0],$val[4], $mon, $year);
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
        qq!<a href="http://$server/about/playerprofile.php?id=$id"><img src="/images/aw/profile1.gif" title="public" alt="public profile" /></a> <a href="http://$server/0/Player/Profile.php/?id=$id"><img src="/images/aw/profile2.gif" alt="personal profile" /></a>\n!;
}
sub alliancedetailslink($) { my($id)=@_;
        qq!<a href="http://$server/0/Alliance/Detail.php/?id=$id"><img src="/images/aw/profile3.gif" alt="member details" /></a>\n!;
}
sub systemlink($) { my($id)=@_;
        qq!<a href="system-info?id=$id">info for system $id</a>\n!;
}

sub alliancelink($) { my($atag)=@_;
   a({-href=>"alliance?alliance=$atag&omit=9+12"},"[$atag]");
}


sub addplayerir($@@;$@@) { my($oldentry,$sci,$race,$newlogin,$trade,$prod)=@_;
	foreach($race,$sci,$trade) {next unless defined $_; if(!@$_){$_=undef}}
	if($race) {$race="race:".join(",",@$race);} else {undef $race}
	if($sci) {
      my @oldsci=relation2science($oldentry);
      if($oldsci[0] && $oldsci[0]>100) {shift @oldsci}
      for my $i(0..7) { $oldsci[$i]=$$sci[$i] if defined($$sci[$i]);}
      $sci="science:".time().",".join(",",@oldsci);
   } else {undef $sci}
	if($trade) {$trade="trade:".join(",",@$trade);} else {undef $trade}
	if($prod) {$prod="production:".join(",",@$prod);} else {undef $prod}
	if(!$oldentry) {$oldentry="0 UNKNOWN "}
	my ($rest,$magic)=($oldentry,$magicstring." ");
	if($oldentry=~/^(\d+ \w+ .*)(?=$magicstring)(.*)/s){
		($rest,$magic)=($1,$2);
	}
#	if(!$magic) {$magic=$magicstring." "}
	if($trade && $magic!~s/trade:\S*/$trade/) {$magic=~s/automagic:/$&\n$trade /}
	if($prod && $magic!~s/production:\S*/$prod/) {$magic=~s/automagic:/$&\n$prod /}
	if($sci && $magic!~s/science:[-+,.0-9]*/$sci/) {$magic=~s/automagic:/$&\n$sci /}
	if($race && $magic!~s/race:[-+,0-9]*/$race/) {$magic=~s/automagic:/$&\n$race /}
	if($newlogin) {
		my @l2=@$newlogin;
		my $add=1;
		if($oldentry=~/$l2[0]:(\d+):(\d+):(\d+)/) {
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
sub relation2production($) { local $_=$_[0];
	return undef unless($_);
	return undef unless(/automagic/);
	return undef unless(/production:(\S*)/);
	my @prod=split(",", $1);
	my @race=relation2race($_[0]);
	return undef unless @race;
	for(my $i=0; $i<7; ++$i){$race[$i]+=0;$race[$i]*=$racebonus[$i]}
	my $a=$prod[3];
	my $t=1+$prod[4]*0.01;
	my @bonus=($t,$t,$t,$t);
	if($a=~/(\w+)(\d)/) {
		my $effect=$artifact{$1}||0;
		for(my $i=0; $i<@race; ++$i) {
			if((1<<$i) & $effect)
			{$race[$i]+=0.1*$2}
		}
	}
	$bonus[0]+=$race[3]; # prod
	$bonus[1]+=$race[1]; # sci
	$bonus[2]+=$race[2]; # cul
	$bonus[3]+=$race[0]; # grow
	push(@prod, \@bonus);
#	for(my $i=0; $i<3; ++$i){ $prod[$i]+=$bonus[$i]; }
	return @prod;
}

sub gmdate($) {
	my @a=gmtime($_[0]); $a[5]+=1900;
	return "$month[$a[4]] $a[3] $a[5]";
}

# input AW title string
# output timezone shift relative to UTC in seconds (e.g. CET=3600)
sub guesstimezone($) {my($title)=@_;
   my $utc=time();
   return undef unless $title=~m/(\d\d):(\d\d):(\d\d)/;
   my $localt=$1*3600+$2*60+$3;
   my $diff=$localt-($utc%86400);
   return ($diff+86400/2)%86400-86400/2;
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

sub file_content($) {my($fn)=@_;
   open(FCONTENT, "<", $fn) or return undef;
   local $/;
   my $result=<FCONTENT>;
   close(FCONTENT);
   return $result;
}

1;
