use strict;
package mangle::special_color_incomings;
use awinput;

sub add_fleets($$) { my($sid,$pid)=@_;
   return "" if(!$sid || !$pid || !$ENV{REMOTE_USER});
   my $sidpid=sidpid22sidpid3m($sid,$pid);
   my $fleets=awinput::get_fleets($sidpid, "AND `iscurrent` = 1");
   return "" if(!$fleets || !@$fleets);
   my $fstr="";
   foreach my $f (@$fleets) {
      my $fs="<br>\n".awinput::show_fleet($f);
      $fs=~s/<a href="(relations\?id=)/$::bmwlink\/$1/;
      $fstr.=$fs;
   }
   $fstr=~s/^<br>//;
   return "<div class=bmwincoming>$fstr</div>";
}


# emphasize important incomings 
sub mangle_incoming() {
#   s%width=135 bgcolor="#894900" align=center>18:58:39 - May 19.*?<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/?id=(\d+)%$&%;
#going to attack <b>Alpha Kelb Alrai</b>          [914] 2
s%(going to attack )(<b>[^<]*</b>\s*)\[(\d+)\] (\d+)(!<br>[^.]*\.php[^.]*\.)%qq'$1$::bmwlink/system-info?id=$3">$2 [$3]</a> $4$5'.add_fleets($3,$4)%ge;

s%(<b>Attention !!!</b> We have evidence of an incoming fleet around that time. <br>)(\d+ Transports.*?going to attack)%$1<span style="background-color:#800">$2</span>%g;
}

1;
