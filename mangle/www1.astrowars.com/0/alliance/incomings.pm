
sub testownalli
{
   my($epid)=@_;
   my $ealli=playerid2alliance($epid);
   if(!$ealli) {return 0}
   my $oalli=playerid2alliance(playername2id($::options{name}));
   if($oalli!=$ealli) {return 0}
   return 1;
}

sub addstyle
{
   my($str,$pid)=@_;
   if(testownalli($pid)) {
      return "<span class=\"bmwownfleet\">$str</span>";
   }
   return $str;
}


require "mangle/special/color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();

s%(width=135 bgcolor=#894900 align=center>\d\d:\d\d:\d\d - \w{3} \d{1,2}.*?)(<br>We suppose its the Fleet of <a href=/0/Player/Profile.php/\?id=)(\d+)([^>]*>[^>]*</a>)%$1.addstyle($2.$3.$4, $3)%ge;

2;
