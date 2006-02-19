package mangle::dispatch;
use strict;
use awstandard;
use awinput;
use DBAccess;
use Time::HiRes qw(gettimeofday tv_interval); # for profiling

our $g;
my $origbmwlink="<a class=\"awtools\" href=\"http://$bmwserver/cgi-bin";
my $notice="";#<b style=\"color:green\">notice: brownie + AWTools server will have a scheduled maintenance period next morning (2006-02-01 03:30-07:00 UTC). Do not worry about errors then. Just reload a bit later.</b><br>";

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
   $g=$$options{name} eq "greenbird";
   my $t2=[gettimeofday];
   %::options=%$options;
   $::bmwlink=$origbmwlink;
   my %info=("alli"=>$ENV{REMOTE_USER}, "user"=>$$options{name}, "proxy"=>$$options{proxy}, "ip"=>$$options{ip});
   my $gameuri=defined($url) && $url=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $url=~m%^http://www1\.astrowars\.com/0/%;
   my $title="";
   my $alli="\U$ENV{REMOTE_USER}";
   
   if(m&<title>([^<]*)</title>&) {
      $title=$1;
   } else { $title="special_no_title" }

# add main AWTool link
      if((my $session=awstandard::cookie2session(${$$options{headers}}{Cookie}))) {
         my $nclicks="";
         my $sth2=$dbh->prepare_cached("SELECT `nclick` FROM `usersession` WHERE `sessionid` = ?");
         my $aref=$dbh->selectall_arrayref($sth2, {}, $session);
         $nclicks=$$aref[0][0];
         if(defined($nclicks)) {$nclicks++}
         else {$nclicks=1}
         if($nclicks>290) {$nclicks=qq'<b style="color:#f44">$nclicks</b>'}
         $info{clicks}=$nclicks;
         if($ENV{REMOTE_USER}) {
            $::bmwlink="$origbmwlink/modperl/public/authaw?session=$session&uri=/cgi-bin";
         }
      }
      
      $::extralink="$::bmwlink/index.html\">AWTools</a>";
      $::options{title}=$title;
      my @module=();
      my $module=title2pm($title);
      push(@module, url2pm($url), ($gameuri ? $module :()));
      foreach my $m (@module) {
         my $include="mangle/$m.pm";
         next if(!-e $include);
         my $ret=do $include;
         next if $ret==2;
         if($@) {$module="error in $m: $@";}
         else { $module="mangled $m";} # for the log
         # is handled now, so stop filtering
         last;
      }
#      $module="($module)"; #qq'<span style="color:gray">($module)</span>';
      if($g) {
         $info{page}=join(", ",@module). " $module";
      } else { $info{page}=$module }

      if($ingameuri) {
         if($g || $$options{name} eq "Mythwin") {
            eval q§
               my $sep="<td>|</td>";
               my $e="</a></td>";
               my $s=qq'<td class="white">$::bmwlink';
               my $l="$e$sep$s";
               s%^</tr></table>%</tr><tr><td width="140" bgcolor="#202060"></td><td colspan="13"> &nbsp; </td></tr><tr height=15 align="center"><td width="140" bgcolor="#206020"><b>$::extralink</b>$e
                  $s/arrival">arrival
                  $l/tactical">tacmap
                  $l/tactical-large">tlarge
                  $l/tactical-live">tlive
                  $l/relations">player
                  $l/alliance">alliance
                  $l/fleets">fleets$e$&%m;
#               $_.="test OK";
            § or $_.= $@;
         } else {
            s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a></td>%;
         }
      }

   do "mangle/special/dispatch.pm"; mangle::special::mangle();
# colorize player links
   require "mangle/special/color.pm"; mangle::special::color::mangle();

#   s%<br>\s*(<TABLE)%$1%; # remove some blanks

# add footer + disclaimer
   my $online="";
   if($alli && $$options{name}) {
      my $now=time();
      my $reltime=$now-60*25;
      my $allimatch=" AND `aid` = `alliance` AND e.name = player.name AND `tag` LIKE ? ";
      my $allifrom=",`player`,`alliances`";
      if(0 && $g) {$allimatch=$allifrom=""}
      my $t1=[gettimeofday];
      my $sth=$dbh->prepare_cached("SELECT distinct e.`name` , `lastclick`
         FROM usersession AS e, (
               SELECT max( i.lastclick ) AS t
               FROM `usersession` AS i
               GROUP BY `name`
               ) AS m$allifrom
         WHERE e.lastclick = m.t
         AND `lastclick` > ? $allimatch
         AND e.`name` != ?
         ORDER BY `lastclick` DESC");
#      my $sth=$dbh->prepare_cached("SELECT usersession.name,`lastclick` 
#           FROM `usersession` $allifrom 
#           WHERE `lastclick` > ? $allimatch AND usersession.name != ?
#           GROUP BY usersession.name
#           ORDER BY lastclick DESC;");
      $sth->execute($reltime, ($allimatch?$alli:()), $$options{name});
      $$options{sqlelapsed}=tv_interval ( $t1 );
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
         $online="<span class=\"bottom_key\">allies online:</span> $online<br>"
      }
   }
   if(!$alli) {$alli=qq!<b style="color:red">no</b>!}
   my $info=join(" ", map({"<span class=\"bottom_key\">$_=</span>$info{$_}"} sort keys %info));
   $$options{totalelapsed}=tv_interval ( $t2 );
   my $gbcontent="<!-- start greenbird disclaimer -->\n<p style=\"text-align:center; color:white; background-color:black\">disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again.<br>$notice$online$info</p>\n<!-- end greenbird disclaimer -->\n";

   if($ingameuri) {
      my $style=$g?"awmod":"awmod";
      if(m%<b>Please Login Again.</b></font>%) {$style="awlogin";}
      if($$options{name} eq "snappyduck") {$style="snappy/main"}
      s%<style type="text/css"><[^<>]*//-->\n</style>%<link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/code/css/$style.css">%;
   }
   if($gameuri || $g) {
      # fix AR's broken HTML
      s%</body>%$gbcontent $&%;
      if($g) {
         $_.=sprintf(" benchmark: pre:%ims aw:%ims sql:%ims mangle:%ims ", $$options{prerequestelapsed}*1000, $$options{awelapsed}*1000, $$options{sqlelapsed}*1000, $$options{totalelapsed}*1000);
#         s%^%<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n "http://www.w3.org/TR/html4/loose.dtd">\n%;
#         s%BODY, H1, A, TABLE, INPUT{%BODY {\nmargin-top: 0px;\nmargin-left: 0px;\n}\n $&%;
#         if($url=~m%^http://www1.astrowars.com/rankings/%){ s%</form>%%; }
      }
      # fix AR's non-standard HTML
      s%(<a href=)([a-zA-Z0-9/.:?&\%=-]+)>%$1"$2">%g;
   }
}

1;
