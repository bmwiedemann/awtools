package mangle::dispatch;
use strict;
use awstandard;
use awinput;
use DBAccess;

my $origbmwlink="<a href=\"http://$bmwserver/cgi-bin";
my $notice="";#<b style=\"color:green\">notice: brownie + AWTools server will have a scheduled maintenance period this morning (2006-01-23 02:30-06:00 UTC). Do not worry about errors then. Just reload a bit later.</b><br>";

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

# input options hash reference
# input $_ with HTML code of a complete page
# output $_ with HTML of mangled page
sub mangle_dispatch(%) { my($options)=@_;
   my $url=$$options{url};
   if($url && $url=~m%/images/%) {return}
   %::options=%$options;
   $::bmwlink=$origbmwlink;
   my %info=("alli"=>$ENV{REMOTE_USER}, "user"=>$$options{name}, "proxy"=>$$options{proxy}, "ip"=>$$options{ip});
   my $gameuri=defined($url) && $url=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $url=~m%^http://www1\.astrowars\.com/0/%;
   my $title="";
   my $alli="\U$ENV{REMOTE_USER}";
   
   if($url=~m%^http://www\.astrowars\.com/about/battlecalculator%) {
      s/(form action="" method=")post/$1get/;
   }
   if($gameuri && m&<title>([^<]*)</title>&) {
      $title=$1;

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
      }
      
      $::extralink="$::bmwlink/index.html\">AWTools</a>";
      $::options{title}=$title;
      my @module=();
      my $module=title2pm($title);
      push(@module, url2pm($url), $module);
      foreach my $m (@module) {
         my $include="mangle/$m.pm";
         next if(!-e $include);
         do $include;
         if($@) {$module="error in $m: $@";}
         else { $module="mangled $m";} # for the log
         # is handled now, so stop filtering
         last;
      }
#      $module="($module)"; #qq'<span style="color:gray">($module)</span>';
      if($::options{name} eq "greenbird") {
         $info{page}=join(", ",@module). " $module";
      } else { $info{page}=$module }

      if($ingameuri) {
         if(0 && $::options{name} eq "greenbird") {
#            eval q§
               my $sep="<td>|</td>";
               my $e="</a></td>";
               my $s=qq'<td class="white">$::bmwlink';
               my $l="$e$sep$s";
               s%^</tr></table>%</tr><tr><td width="140" bgcolor="#202060"></td><td colspan="13"> &nbsp; </td></tr><tr height=15 align="center"><td width="140" bgcolor="#202060"><b>$::extralink</b>$e
                  $s/arrival">arrival
                  $l/tactical">tacmap
                  $l/tactical-large">tlarge
                  $l/tactical-live">tlive
                  $l/relations">player
                  $l/alliance">alliance
                  $l/fleets">fleets$e$&%m;
#               $_.="test OK";
#            § or $_.= $@;
         } else {
            s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a></td>%;
         }
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
   my $online="";
   if($alli && $$options{name}) {
      my $now=time();
      my $reltime=$now-60*25;
      my $allimatch=" AND `aid` = `alliance` AND usersession.name = player.name AND `tag` LIKE ? ";
      my $allifrom=",`player`,`alliances`";
      if(0 && $$options{name} eq "greenbird") {$allimatch=$allifrom=""}
      my $sth=$dbh->prepare_cached("SELECT usersession.name,`lastclick` 
            FROM `usersession` $allifrom 
            WHERE `lastclick` > ? $allimatch AND usersession.name != ?
            GROUP BY usersession.name
            ORDER BY lastclick DESC;");
      $sth->execute($reltime, ($allimatch?$alli:()), $$options{name});
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
   my $gbcontent="<p style=\"text-align:center; color:white; background-color:black\">disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again.<br>$notice$online$info</p>";

   if($gameuri) {
      # fix AR's broken HTML
      if($url eq "http://www1.astrowars.com/") {
         s%^%<html><head><title>Greenbird's Astrowars 2.0 Login</title></head> <link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/aw.css"><body>%;
         s%$%</body></html>%;
      }
      s%</body>%$gbcontent $&%;
      if($::options{name}=~m/greenbird|neron92/) {
         s%^%<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n "http://www.w3.org/TR/html4/loose.dtd">\n%;
         s%BODY, H1, A, TABLE, INPUT{%BODY {\nmargin-top: 0px;\nmargin-left: 0px;\n}\n $&%;
#         if($url=~m%^http://www1.astrowars.com/rankings/%){ s%</form>%%; }
         # fix color specification
          s%bgcolor="([0-9a-fA-F]{6})"%bgcolor="#$1"%g;
      }
      s%(<a href=)([a-zA-Z0-9/.:?&\%=-]+)>%$1"$2">%g;
      s%</head>%<link type="image/vnd.microsoft.icon" rel="icon" href="http://aw.lsmod.de/awfavicon.ico">\n<link rel="shortcut icon" href="http://aw.lsmod.de/awfavicon.ico">$&%;
   }
}

1;
