s%</tr>\n</table>\n<br>%<td>|</td>
<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>$&%;


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

#if($::options{name} eq "greenbird") {
   s&(<td><a href="?Detail.php/\?i=\d+"?>[^<]* \d+</a></td>)<td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td></tr>&$1.replace_buildings_colour($2,$3,$4,$5,$6,$7)."</tr>"&ge;
#}

1;
