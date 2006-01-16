package mangle::dispatch;
use strict;
use awstandard;
use awinput;
use DBAccess;

my $origbmwlink="<a href=\"http://$bmwserver/cgi-bin";

sub mangle_dispatch(%) { my($options)=@_;
   my $url=$$options{url};
   if($url && $url=~m%/images/%) {return}
   %::options=%$options;
   $::bmwlink=$origbmwlink;
   my %info=("alli"=>$ENV{REMOTE_USER}, "user"=>$$options{name}, "proxy"=>$$options{proxy}, "ip"=>$$options{ip});
   my $gameuri=defined($url) && $url=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $url=~m%^http://www1\.astrowars\.com/0/%;
   my $title="";
   my $module="";
   my $alli="\U$ENV{REMOTE_USER}";
   
   if($url=~m%^http://www\.astrowars\.com/about/battlecalculator%) {
      s/(form action="" method=")post/$1get/;
   }
   if($gameuri && $url=~m%^http://www1\.astrowars\.com/rankings/alliances/(\w+)\.php%) { my $tag=$1;
      s%^</td></tr></table>%$& $::bmwlink/alliance?alliance=$tag">AWtools($tag)</a><br>%m;
   }
   if($gameuri && m&<title>([^<]*)</title>&) {
      $title=$1;
      $module=title2pm($title);

# add main AWTool link
      if(1 && (my $session=awstandard::cookie2session(${$$options{headers}}{Cookie}))) {
         my $nclicks="";
         my $sth2=$dbh->prepare_cached("SELECT `nclick` FROM `usersession` WHERE `sessionid` = ?");
         my $aref=$dbh->selectall_arrayref($sth2, {}, $session);
         $nclicks=$$aref[0][0];
         if(defined($nclicks)) {$nclicks++}
         else {$nclicks=1}
         if($nclicks>290) {$nclicks=qq'<b style="color:#f44">$nclicks</b>'}
         $info{clicks}=$nclicks;
         $::bmwlink="$origbmwlink/authaw?session=$session&uri=/cgi-bin";
         if($ingameuri) {
            s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a></td>%;
         }
#         s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/authaw?session=$session">AWTools</a></td>%;
      }
      
      my $include="mangle/$module.pm";
      if(-e $include) {
         do $include;
         if($@) {$module="error in $module: $@";}
         else { $module="mangled $module"; # for the log
         }
      }
      else {$module="$module"}
#      $module="($module)"; #qq'<span style="color:gray">($module)</span>';
      $info{page}=$module;


# colorize player links
      require "mangle/special_color.pm"; mangle_player_color();

   }

# remove ads
   s/<table><tr><td><table bgcolor="#\d+" style="cursor: pointer;".*//;
# disable ad
   s/(?:pagead2\.googlesyndication\.com)|(?:games\.advertbox\.com)|(?:oz\.valueclick\.com)|(?:optimize\.doubleclick\.net)/localhost/g;
#   s%<br>\s*(<TABLE)%$1%; # remove some blanks

# add footer + disclaimer
   my $online="";
   if($alli && $$options{name}) {
      my $now=time();
      my $reltime=$now-60*25;
      my $sth=$dbh->prepare_cached("SELECT usersession.name,`lastclick` 
            FROM `usersession`,`player`,`alliances` 
            WHERE `lastclick` > ? AND `aid` = `alliance` AND usersession.name = player.name AND `tag` LIKE ? AND usersession.name != ?
            GROUP BY usersession.name
            ORDER BY lastclick DESC;");
      $sth->execute($reltime, $alli, $$options{name});
      my @who2;
      while ( my @row = $sth->fetchrow_array ) {
#      foreach my $row (@$who) {
         my ($name,$time)=@row;
         my $diff=15-int(($now-$time)/60/2);
         if($diff<3) {$diff=3}
         my $c=sprintf("%x", $diff);
#if($time<$now-60*6) {
         push(@who2,"<span style=\"color:#$c$c$c\">$name</span>");
      }
      $online=join(", ", @who2);
      if($online){
         $online="<span style=\"color:gray\">allies online:</span> $online<br>"
      }
   }
   if(!$alli) {$alli=qq!<b style="color:red">no</b>!}
   my $info=join(" ", map({"<span style=\"color:gray\">$_=</span>$info{$_}"} sort keys %info));
   my $gbcontent="<p style=\"text-align:center; color:white; background-color:black\">disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again.<br>$online$info</p>";
   s%</body>%$gbcontent $&%;

   if($gameuri) {
      # fix AR's broken HTML
      if($url eq "http://www1.astrowars.com/") {
         s%^%<html><head><title>Greenbird's Astrowars 2.0 Login</title></head><body>%;
         s%$%</body></html>%;
      }
      if($::options{name} eq "greenbird") {
         s%^%<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n "http://www.w3.org/TR/html4/loose.dtd">\n%;
         s%BODY, H1, A, TABLE, INPUT{%BODY {\nmargin-top: 0px;\nmargin-left: 0px;\n} $&%;
#         if($url=~m%^http://www1.astrowars.com/rankings/%){ s%</form>%%; }
#         s%<center>%$&<div style="margin-left:10px; margin-right:10px">%;
#         s%<table width="400" border=0 align="center"%</center><center>$&%g;
         # fix color specification
          s%bgcolor="([0-9a-fA-F]{6})"%bgcolor="#$1"%g;
      }
      s%(<a href=)([a-zA-Z0-9/.:?&\%=-]+)>%$1"$2">%g;
      s%</head>%<link type="image/vnd.microsoft.icon" rel="icon" href="http://aw.lsmod.de/awfavicon.ico">\n<link rel="shortcut icon" href="http://aw.lsmod.de/awfavicon.ico">$&%;
   }
}

1;
