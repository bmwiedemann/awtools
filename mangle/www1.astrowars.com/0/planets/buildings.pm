use DBAccess2;
#use strict;

use awstandard;
my $data=getparsed(\%::options);

my $sum=0;
foreach my $p (@{$data->{planet}}) {
	my $p=$p->{population}-20;
	next if($p<=0);
	$sum+=$p;
}
s{(Points: )(\d+)(</td>)}{$1.($2+$sum).$3}e;

if(m!<td>Sum</td><td>\d+</td><td>\d+</td><td>\d+</td><td>\d+</td><td>\d+</td><td>(\d+)</td></tr>! && $1>=150) {
   s%\n</tr>\n</table>\n<br>%<td>|</td>
<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>$&%;
}


sub replace_buildings_colour
{
   my $ret="";
   my $pop=shift;
   my $pp=pop;
   my @a=@_;
   foreach my $a (@a) {
      if(5*1.5**$a<=$pp) {
         $a="<span class=bmwbuildingavailable>$a</span>";
      }
   }
   foreach my $a ($pop,@a,$pp) {
      $ret.="<td>$a</td>";
   }
   return $ret;
}

   s&(<td><a href="?Detail.php/\?i=\d+"?>[^<]* \d+</a></td>)<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>&$1.replace_buildings_colour($2,$3,$4,$5,$6,$7)."</tr>"&ge;
#if($::options{name} eq "greenbird") {
	my $dbh=get_dbh();
	my $planets=$dbh->selectall_arrayref(
"SELECT `name`, sidpid DIV 13, sidpid MOD 13, `starbase` FROM `planets`,`starmap` WHERE (sidpid DIV 13)=`sid` AND `ownerid` = ?", {}, $::options{pid});
	my %nhash=();
	my $shash=();
	foreach my $p (@$planets) {
		my($name, $sid, $pid, $sb)=@$p;
		$nhash{"$name $pid"}=$sb;
		$shash{"($sid) $pid"}=$sb;
		#$_.="@$p\n<br>";
	}
	s{(<a href=Detail\.php/\?i=\d+>)(\w[^<>]+ \d+)(</a></td>.*?)(</tr>)}
	 {$1$2$3<td>$nhash{$2}</td>$4}g;
	s{(<a href=Detail\.php/\?i=\d+>)(\(\d+\) \d+)(</a></td>.*?)(</tr>)}
	 {$1$2$3<td>$shash{$2}</td>$4}g;
	s{Production Points</a></td>}
	 {$&<td><a class="awglossary" href="/0/Glossary/?id=16">SB</a></td>};
#}


1;
