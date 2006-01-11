package mangle::dispatch;
use strict;
use awstandard;
use awinput;
use DBAccess;

$::bmwlink="<a href=\"http://$bmwserver/cgi-bin";

sub manglefilter { my($options)=@_;
   %::options=%$options;
   my %info=("alli"=>$ENV{REMOTE_USER}, "user"=>$::options{name});
   my $gameuri=defined($::options{url}) && $::options{url}=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $::options{url}=~m%^http://www1\.astrowars\.com/0/%;
   my $title="";
   my $module="";
   my $alli="\U$ENV{REMOTE_USER}";
   
   if($gameuri && $::options{name} && $::options{url}=~m%^http://www1.astrowars.com/register/login.php% && (my $session=${$::options{headers}}{Cookie})) { # reset click counter now
         $session=~s/^.*PHPSESSID=([^; ]*).*/$1/;
         $dbh->do("UPDATE `usersession` SET `nclick` = '0' WHERE `sessionid` = ".$dbh->quote($session));
   }
   if($::options{url}=~m%^http://www\.astrowars\.com/about/battlecalculator%) {
      s/(form action="" method=")post/$1get/;
   }
   if($gameuri && m&<title>([^<]*)</title>&) {
      $title=$1;
      $module=title2pm($title);
      my $include="mangle/$module.pm";
      if(-e $include) {
         do $include;
         if($@) {$module="error in $module: $@";}
         else { $module="filtered $module"; # for the log
         }
      }
      else {$module="$module"}
#      $module="($module)"; #qq'<span style="color:gray">($module)</span>';
      $info{page}=$module;

# add main AWTool link
      if(1 && $ingameuri && (my $session=${$::options{headers}}{Cookie})) {
         my $nclicks="";
         if($session=~s/^.*PHPSESSID=([a-f0-9]{32}).*/$1/) {
            my $time=time();
            my $result=$dbh->do("UPDATE `usersession` SET `nclick` = `nclick` + 1 , `lastclick` = '$time' WHERE `sessionid` = '$session' LIMIT 1;");
            if($result ne "0E0") {
               my $ref=$dbh->selectall_arrayref("SELECT `nclick` FROM `usersession` WHERE `sessionid` = '$session';");
               $nclicks=$$ref[0][0];
            } else { #insert
              $nclicks=0;
              $dbh->do("INSERT INTO `usersession` VALUES ( '$session', '$::options{name}', '0', '$time', '$time');");
            }
            if($nclicks>290) {$nclicks=qq'<b style="color:#f44">$nclicks</b>'}
            $info{clicks}=$nclicks;
         }
#s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a> $nclicks</td>%;
         s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/authaw?session=$session">AWTools</a></td>%;
      }

# colorize player links
      require "mangle/special_color.pm"; mangle_player_color();

   }

# remove ads
   s/<table><tr><td><table bgcolor="#\d+" style="cursor: pointer;".*//;
# disable ad
   s/(?:pagead2\.googlesyndication\.com)|(?:games\.advertbox\.com)|(?:oz\.valueclick\.com)|(?:optimize\.doubleclick\.net)/localhost/g;
#   s%<br>\s*(<TABLE)%$1%; # remove some blanks

# add footer + disclaimer
   if(!$alli) {$alli=qq!<b style="color:red">no</b>!}
   my $info=join(" ", map({"<span style=\"color:gray\">$_=</span>$info{$_}"} sort keys %info));
   my $gbcontent="<p style=\"text-align:center; color:white; background-color:black\">disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again.<br>$info</p>";
   s%</body>%</center>$gbcontent $&%;

}

sub mangle_dispatch(%) { my($options)=@_;
   if(!$$options{url} || $$options{url}!~m%/images/%) {
      manglefilter($options);
   }
}

1;
