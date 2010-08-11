use strict;
use awinput;

# add next and prev buttons
if($::options{url}=~/id=(\d+)/) {
   my $id=$1;
   my $url="?id=";

   while(1) { # pseudo loop to exit at several places
      my $pid=$::options{pid};
      last unless($pid && $pid>2);
      my $aid=lc(playerid2alliance($pid));
      my $s=is_startofround();
      last unless($aid || $s);
      my $members=awinput::allianceid2membersr($aid)||[];

      my $previd=$id-1;
      my $nextid=$id+1;
      my $prevstring="";

      s%([^<>]*)(<br><table border=0)%
         my $id=playername2id($1);
         my $x=$1;
         if($id) { $x="<a href=\"/0/Player/Profile.php/?id=$id\">$1</a>"; }
         $x.$2%e;
      if($previd>=0) { $prevstring.=qq'<a href="$url$previd" accesskey="p">prev</a>'; }
      if($nextid<@$members || $s) { $prevstring.=qq' <a href="$url$nextid" accesskey="n">next</a>'; }
      my $n=0;
      my $form="";
      if(@$members) {
         $form.=' <form action=""><select style="text-align:left;" name="id" onchange="submit()">';
         foreach my $m (@$members) {
            my $name=playerid2name($m);
            my $sel=($id == $n)?" selected":"";
            $form.=qq' <option value="$n"$sel>$name</option>';
            $n++;
         }
         $form.='</select><input type="submit" class="smbutton" value="Go"></form> ';
      }
   
      s%<br><table border=0%<br>$prevstring$form$&%;
      last;
   }
   do "mangle/www1.astrowars.com/0/alliance.pm";
}

# add classes - but not for main_inner table:
my $n=1;
s%<table border=0 cellpadding=1 cellspacing=1 width=600(?=>)%$&.' class="sub_inner" id="alliance_detail'.($n++).'"'%ge;

require "mangle/special/color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();


# add display of prod with bonus
if(0) {
   my ($trade)=m/<td bgcolor=[^>]*>Trade Revenue<\/td><td>(\d+)%</;
   my ($arti)=m/<td bgcolor=[^>]*>Artifact<\/td><td>([^<]*)</;
   my @bonus=(1,1,1,1);
   foreach my $b (@bonus) {$b+=$trade*0.01}
   if($arti=~/(\w+) (\d)/) {
      my $effect=$awstandard::artifact{$1}||0;
      for(my $i=0; $i<@bonus; ++$i) {
         if((1<<$i) & $effect)
         {$bonus[$i]+=0.1*$2}
      }
   }
   my $n=0;
   foreach my $p (qw(Science Culture Production)) {
      $n++;
      next unless m/<li>([+-]\d+)% \L$p/;
      $bonus[$n]+=$1*0.01;
      s/(<td bgcolor=#303030>$p<\/td><td>\+)(\d+)/$1.$2."=".bmwround($2*$bonus[$n])/e;
   }
#   $_.="<br>t:$trade a:$arti b:@bonus<br>";
}


use awbuilding;
# add data from internalplanet collection
sub popsubst($$$)
{
	my($sid,$pid,$pop)=@_;
	my $v=getbuilding_sidpid($sid,$pid);
	if($v && $v->[0]) {
		my $pop2=$v->[0]->[4];
		my $pp=$v->[0]->[5];
		if($pop2) {
			my $extra="";
			if($pop != int($pop2)) {$extra=$pop." | "}
			$pop=sprintf("%s%.2f",$extra,$pop2);
		}
		if($pp) {
			return "$pop pp:".int($pp);
		}
	}
	return $pop;
}

if(1){#$mangle::dispatch::g) {
	s%(<tr align=center bgcolor=#\d+><td[^>]*>)(\d+)(</td><td>)(\d+)(</td><td>)(\d+)%$1.$2.$3.$4.$5.popsubst($2,$4,$6)%ge;
}

# add system ID tool links
s%(<tr align=center bgcolor=#\d+><td[^>]*>)(\d+)(</td><td>)(\d+)%$1$::bmwlink/system-info?id=$2&target=$4">$2</a>$3$4%g;


1;
