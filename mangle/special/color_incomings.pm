use strict;
package mangle::special_color_incomings;
use awinput;

sub add_fleets($$) { my($sid,$pid)=@_;
   return "" if(!$sid || !$pid || !$ENV{REMOTE_USER});
   my $sidpid=sidpid22sidpid3m($sid,$pid);
   my $fleets=awinput::sidpid2fleets($sidpid, "AND `iscurrent` = 1");
   return "" if(!$fleets || !@$fleets);
   my $fstr="";
   foreach my $f (@$fleets) {
      my $fs=awinput::show_fleet($f);
#      $fs=~s/<a( class="[^"]+")? href="(relations\?id=\d+")/$::bmwlink\/$2$1/;
      $fstr.="<br>\n".$fs;
   }
   $fstr=~s/^<br>//;
   return "<div class=bmwincoming>$fstr</div>";
}


# emphasize important incomings 
sub mangle_incoming() {
#   s%width=135 bgcolor="#894900" align=center>18:58:39 - May 19.*?<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/?id=(\d+)%$&%;
#going to attack <b>Alpha Kelb Alrai</b>          [914] 2
s%<a href="\.\./Map/Detail\.php\?nr=(\d+)">ID \d+ - [^#]+ #(\d+)</a><br />\s*(?:<span class="\w+">)?<a href="\.\./Player/Profile\.php\?id=\d+">.+</a>%$&.add_fleets($1,$2)%ge;
s%<a href="\.\./Map/Detail\.php\?nr=(\d+)">ID \d+ - [^#]+ #(\d+)</a><br/>\s*We suppose it's the fleet of <a href="\.\./Player/Profile\.php\?id=\d+">.+</a>%$&.add_fleets($1,$2)%ge;
#s%(going to attack )(<b>[^<]*</b>\s*)\[(\d+)\] (\d+)(!<br>[^.]*\.php[^<]*</a>\.)%"$1$::bmwlink".awstandard::awsyslink($3,0,$4)."$2 [$3]</a> $4$5".add_fleets($3,$4)%ge;

#s%(<b>Attention !!!</b> We have evidence of an incoming fleet around that time. <br>)(\d+ Transports.*?going to attack)%$1<span style="background-color:#800">$2</span>%g;
}

1;
