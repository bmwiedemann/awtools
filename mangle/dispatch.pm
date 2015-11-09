package mangle::dispatch;
use strict;
use awstandard;
use awinput;
use bbcode;
use awaccess;
use awsql;
use DBAccess;
use awimessage;
use Time::HiRes qw(gettimeofday tv_interval); # for profiling
use mangle::special::dispatch;
use mangle::special::use_css;
use mangle::special::color;
use mangle::special::secure_nice;

our $g;
my %specialname=qw(
      greenbird 1
      pentabarf 1
      Banana9977 1
      cutebird 1
      PedroMorello 1
);
my $origbmwlink="<a class=\"awtools\" href=\"//$bmwserver/cgi-bin";

# input options hash reference
# input $_ with HTML code of a complete page
# output $_ with HTML of mangled page
sub mangle_dispatch(%) { my($options)=@_;
   my $url=$$options{url};
   $g=$specialname{$$options{name}}||($$options{ip} eq "217.11.53.122");
   my $t2=[gettimeofday];
   $$options{bmwlink}=$::bmwlink=$origbmwlink;
   $$options{authlink}=$origbmwlink;
   %::options=%$options;
   $toolscgiurl="//$bmwserver/cgi-bin/"; # this is initially empty but for mangling we need absolute URLs

   my $notice="";#<b style=\"color:green\">notice: road works ahead.... brownie + AWTools server has a scheduled maintenance period today (Monday 2007-03-26 12-18:00 UTC) and might be temporarily unavailable then. Do not worry about errors during this time. Just reload a bit later.</b> (there is a known issue with some browsers' processing of .pac files that causes it to not use the proxy even after it is back running - the work-around for that problem is then to close all browser windows)<br/>";

#   local $ENV{REMOTE_USER}=$ENV{REMOTE_USER};
#   if($$options{name} eq "mauritz") { # map user to see AF data, but not feed
#      $ENV{REMOTE_USER}="af";
#   }
   
   my @accesstexts=(
      "Your alliance is using greenbird's extended AWTools but has not yet decided to NAP or pay this round. The founder can decide <a href=\"//$bmwserver/cgi-bin/alliopenaccount\">here</a>",
      "Your alliance has paid for greenbird's extended AWTools this round. Thanks!",
      "Your alliance is using greenbird's extended AWTools for a <a href=\"//aw.zq1.de/manual.html#policy\">NAP</a> with greenbird's alliance for this round");
   my %info=("alli"=>$ENV{REMOTE_USER}, "pid"=>$$options{pid}, "user"=>$$options{name}||"?", "proxy"=>$$options{proxy}, "ip"=>$$options{ip});
   my $gameuri=defined($url) && $url=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $url=~m%^http://www1\.astrowars\.com/0/%;
   my $joinlink="";
   my $alli="\U$ENV{REMOTE_USER}";
	my $agent="";
   
   # greenbird special
	if($::options{req}) {
		my $h=$::options{req}->headers_in();
		$agent=$h->get("User-Agent");
		if($g) {
			$info{url}=$h->get("Host");
			$info{agent}=$agent;
		}
		if($agent=~m/BlackBerry|Android|iPhone|Maemo|IEMobile|Symbian/) {
			$::options{handheld}=1;
		}
	}
   if(m/<form id="loginSecurity"/) {
      if($g) {
         if(do "mangle/special/secure.pm") {
            $_=mangle::special::secure::mangle($_);
         }
      }
      mangle::special::secure_nice::mangle($_);
   }

   
# add main AWTool link
      if((my $session=$$options{session})) {
         my $nclicks="";
         #my $sth2=$dbh->prepare_cached("SELECT `nclick` FROM `usersession` WHERE `sessionid` = ?");
         #my $aref=$dbh->selectall_arrayref($sth2, {}, $session);
         $nclicks=$$options{nclick};#$$aref[0][0];
         if(defined($nclicks)) {$nclicks++}
         else {$nclicks=1}
			$::options{nclicks}=$nclicks;
         if($nclicks>290) {$nclicks=qq'<b style="color:#f44">$nclicks</b>'}
         $info{clicks}=$nclicks;
         $$options{authlink}="$origbmwlink/public/authaw?session=$session&amp;uri=/cgi-bin";
         if($ENV{REMOTE_USER}) {
            $::bmwlink=$$options{authlink};
         }
         if($ENV{REMOTE_USER}) {
            # inform user about his terms of use
            my($flags)=$dbh->selectrow_array("SELECT `flags` FROM `toolsaccess` WHERE tag=? and othertag=tag",{},$ENV{REMOTE_USER});
            if($flags<=@accesstexts) {
               $joinlink.="<br/><span class=\"bmwinfo\" id=\"termsofaccess\">$accesstexts[$flags]</span> ";
            }
         }
         if(($interbeta || !$ENV{REMOTE_USER}) && $$options{pid}) {
            my $atag=playerid2tag($$options{pid});
            if(($interbeta || !$atag) && $$options{name} && ($$options{name} ne "unknown")) {
               $joinlink="<br/>".$$options{authlink}."/joinalli\">I am member of an alliance that already uses extended AWTools and want to join</a>";
            } elsif(is_founder($$options{pid})) {
               # if alliance founder, add extra "accept NAP with AF" link
               $joinlink.="<br/>$$options{authlink}/public/alliopenaccount\">As founder of an alliance I want to use AWTools</a> ";
               #$joinlink.="<br/><a href=\"//aw.zq1.de/manual.html#policy\">As founder of an alliance I want to use AWTools</a> ";
            }
         } else {
         }
      }
      
      $::extralink="$::bmwlink/index.html\">AWTools</a>";
      my @module=();
      my $module="";
      push(@module, url2pm($url));
      foreach my $m (@module) {
         my $include="$awstandard::codedir/mangle/$m.pm";
         next if(!-e $include);
         my $ret=do $include;
         next if $ret==2;
			if($ret==30) {
				return; # return $_ verbatim
			}
         if($@) {$module="error in $m: $@";}
         else { $module="mangled $m";} # for the log
         # is handled now, so stop filtering
         last;
      }
#      $module="($module)"; #qq'<span style="color:gray">($module)</span>';
      if(0 && $g) {
         $info{page}=join(", ",@module). " $module";
      } else { $info{page}=$module }

      if($ingameuri) {
         if(1||$alli) {
#            eval q§
               my $sep="";
               my $e="</a></li>\n";
               my $s=qq'<li class="white">$::bmwlink';
               my $l="$e$sep$s";
               s%^(  <div id="menu".*?)(</div>)%$1<ul class="t_bmw_navi_links"><li class="t_bmw_navi_title"><b>$::extralink</b></li>
                  $s/preferences2">prefs
                  $l/tactical-live2">tacmap
                  $l/system-info">system
                  $l/relations">player
                  $l/imessage">BIM
                  $l/alliance">alliance
                  $l/fleets">fleets$e</ul>$2%sm;
#               $_.="test OK";
#            § or $_.= $@;
         } else {
            s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a></td>%;
         }
			s{(<table)(><tr><td><table bgcolor="#\d+" style="cursor: pointer;"cellspacing="0" )}{$1 class="bottomad"$2};
      }

#   do "mangle/special/dispatch.pm"; 
   mangle::special::mangle();
# colorize player links
#   do "mangle/special/color.pm"; 
   mangle::special::color::mangle();

#   s%<br/>\s*(<TABLE)%$1%; # remove some blanks

# add footer + disclaimer
   my $imessage="";
   if($$options{pid}) {
      $$options{authpid}=$$options{pid};
      my $ims=awimessage::get_all_ims($options, 1);
      if($ims && @$ims) { # have im
         my $nims=@$ims;
         my $bims=$nims>1?"$nims BIMs":"a BIM";
         $imessage="<!-- start gb imessage --><div class=\"awimessage\">You have received $$options{authlink}/imessage\">$bims</a>.<br/>";
         my $imend="</div><!-- end gb imessage -->\n";
         s!<center>!$imessage$imend$&!;
         foreach my $im (@$ims) {
            my ($imid,$time,$sendpid,$recvpid,$msg)=@$im;
            my $fromto;
            my $c;
            if($sendpid==$$options{authpid}) {
               $fromto=" =&gt; ".playerid2link2($recvpid);
               $c="sentimessage";
            } else {
               $fromto=" &lt;= ".playerid2link2($sendpid);
               $c="recvimessage";
            }
            $imessage.=AWisodatetime($time+3600*$$options{tz})."$fromto <span class=\"$c\">".bbcode_trans($msg)."</span> <br/>";
         }
         $imessage.=$imend;
      }
   }
   my $online="";
   if($alli && $$options{name}) {
      my $t1=[gettimeofday];
      my $now=time();
      my $reltime=$now-60*25;
      my $sth;
      if(0 && !$g) {
         my @alli=(lc($alli));
         my $allimatch=" AND `aid` = `alliance` AND ( `tag` = ? ";
         foreach my $a (@{$read_access{lc($alli)}}) {
            $allimatch.=" OR `tag` = ? ";
            push(@alli,$a);
         }
         $allimatch.=" )";
#      my $allifrom=",`player`,`alliances`";
#      if(0 && $g) {$allimatch=$allifrom=""}
         $sth=$dbh->prepare_cached("SELECT player.`name` , m.`t`
            FROM (
                  SELECT max( i.lastclick ) AS t, pid
                     FROM `usersession` AS i
                     WHERE `lastclick` > ? 
                     AND `name` != ?
                     GROUP BY `pid`
                  ) AS m,`player`,`alliances`
            WHERE m.pid = player.pid
             $allimatch
            ORDER BY `t` DESC");
#      my $sth=$dbh->prepare_cached("SELECT usersession.name,`lastclick` 
#           FROM `usersession` $allifrom 
#           WHERE `lastclick` > ? $allimatch AND usersession.name != ?
#           GROUP BY usersession.name
#           ORDER BY lastclick DESC;");
         $sth->execute($reltime, $$options{name}, @alli);
      } else {
         my($allimatch,$amatchvars)=get_alli_match2($alli, 16, "alliances.tag");
         my($allimatch2,$amatchvars2)=get_alli_match2($alli, 16);
         $sth=$dbh->prepare_cached("
               (SELECT player.name, lastclick_at
               FROM toolsaccess, brownieplayer, player, alliances
               WHERE brownieplayer.pid = player.pid AND
               alliance = aid AND
               lastclick_at > ? AND
               $allimatch)

               UNION DISTINCT 
               (SELECT player.name, lastclick_at
               FROM `useralli` , player, brownieplayer, toolsaccess
               WHERE brownieplayer.pid = player.pid
               AND player.pid = useralli.pid
               AND lastclick_at > ?
               AND $allimatch2)
               ORDER BY lastclick_at DESC 
               "); # would need join with alliances,toolsaccess and $allimatch in 2nd part
         $sth->execute($reltime, @$amatchvars, $reltime, @$amatchvars2);
      }
      my @who2;
      while ( my $row = $sth->fetchrow_arrayref ) {
#      foreach my $row (@$who) {
         my ($name,$time)=@$row;
         next if ($name eq $$options{name});
         my $diff=15-int(($now-$time)/60/2);
         if($diff<3) {$diff=3}
         my $c=sprintf("%x", $diff);
#if($time<$now-60*6) {
         push(@who2,"<span class=\"gray$diff\">$name</span>");
      }
      $$options{sqlelapsed}=tv_interval ( $t1 );
      $online=join(", ", @who2);
		my $untagged=$dbh->selectall_arrayref("SELECT playerextra.name,level  FROM `useralli`,playerextra LEFT JOIN `player` ON player.pid=playerextra.pid WHERE `alli`=? AND useralli.pid=playerextra.pid 
		ORDER BY `level`,playerextra.name", {}, $alli);
		if($untagged && @$untagged) {
		   my $x="";
			my @list=();
			foreach my $p (@$untagged) {
				$x="$p->[0]";
				if($p->[1]) {
					$x.=" (PL $p->[1])";
				}
				push(@list,$x);
			}
			$online.="<br/><span class=\"bmwinfo\">untagged $alli players: ".join(", ", @list)."</span>";
		}
      if($online){
         $online="<span class=\"bottom_key\">allies online:</span> $online<br/>"
      }
   }
#   if($alli eq "TGD" || $alli eq "AF" || $alli eq "RATS") {$notice="<b style=\"color:green\">note: RSA forum is down - backup forum is at <a href=\"http://s3.invisionfree.com/RSA_Outpost/index.php?act=idx\">http://s3.invisionfree.com/RSA_Outpost/</a>.</b><br/>"}

   # aw21 transition
   if($$options{proxy} eq "brownie-cgi") {
		#$notice.="<br/><b style=\"color:green\">notice: Dear brownie-cgi user, please also try the faster <a href=\"http://aw21.zq1.de/\">aw21.zq1.de</a> or even the fully integrated <a href=\"http://aw.zq1.de/manual/proxy-config\">brownie.pac</a></b><br/>";
   }
   
   if(!$alli) {$alli=qq!<b style="color:red">no</b>!}
   if($options->{pid}) {
      my($u,$loginat)=get_one_row("SELECT `lastupdate_at`,`prevlogin_at` FROM `brownieplayer` WHERE `pid`=?", [$options->{pid}]);
      if($u) {
         $u=$u-time+$awstandard::updatetime15;
         $info{nextupdate}=$u."s";
      }
      if($loginat) {
         $info{prevlogin}=sprintf("%.1fh",($loginat-time)/3600);
      }
   }
   my $info=join(" ", map({"<span class=\"bottom_key\">$_=</span><span class=\"bottom_value\">$info{$_}</span>"} sort keys %info));
   $$options{mangleelapsed}=$$options{totalelapsed}=tv_interval ( $t2 );
   my $gbcontent="\n$imessage<!-- start greenbird disclaimer -->\n$joinlink<p id=\"disclaimer\"><br/>disclaimer: this page was mangled by greenbird's code. <br/>This means that errors in display or functionality might not exist in the original page. <br/>If you are unsure, disable mangling and try again.</p><p id=\"bmwinfo\">$notice$online$info</p>\n<!-- end greenbird disclaimer -->\n";

   if($gameuri) {
      my $style="main";
      if(m%<legend>Please login again</legend>%) {
			$style="awlogin";
			s/id="user"/$& autofocus="autofocus"/;

		}
      elsif(m%Enter the characters as they are shown in the box below%) {$style="awlogin";}
      elsif($url=~m!astrowars\.com/(rankings|about)/!) {$style="awlogin";}
      
      my @style=($style);
      if($ENV{REMOTE_USER}) { unshift(@style,"alli/$ENV{REMOTE_USER}/$style") }
      if($$options{name}) { unshift(@style, "user/".safe_encode($$options{name})."/$style") }
      foreach my $s (@style){
         if(-r "$awstandard::cssdir/$s.css") {$style=$s;last;}
      }
		my $extracss="//$bmwserver/code/css/style_mobile.css";
		if($agent=~m/iPhone/) {$extracss="//iphoneaw.zq1.de/main.css"}
		s%  <link rel="stylesheet" type="text/css" media="screen" href=%$&"//$bmwserver/code/css/$style.css" />\n$&%;
#      s%<style type="text/css"><[^<>]*//-->\s*</style>%<link rel="stylesheet" type="text/css" href="//$bmwserver/code/css/$style.css">
#<link rel="stylesheet" href="$extracss" media="handheld" type="text/css" />
#<!--[if !IE]>-->
#<link type="text/css" rel="stylesheet" media="only screen and (max-device-width: 480px)" href="$extracss" />
#<!--<![endif]-->
#%;
   }
   if($gameuri || $g) {
      # fix AR's broken HTML

		s!accesskey="1">Astro Wars</a></li>!accesskey="1">AW</a></li>!;
      if($g) {
         s{</head>}{<meta name="viewport" content="width=device-width, initial-scale=1">\n$&}; # for mobile devices
         $gbcontent.=sprintf(" benchmark: auth:%ius pre:%ius aw:%ius sql:%ius mangle:%ius ", $$options{authelapsed}*1000000, $$options{prerequestelapsed}*1000000, $$options{awelapsed}*1000000, $$options{sqlelapsed}*1000000, $$options{mangleelapsed}*1000000);
#         s%^%<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"\n "http://www.w3.org/TR/html4/loose.dtd">\n%;
#         s%BODY, H1, A, TABLE, INPUT{%BODY {\nmargin-top: 0px;\nmargin-left: 0px;\n}\n $&%;
#         if($url=~m%^http://www1.astrowars.com/rankings/%){ s%</form>%%; }
      }
      s%</body>%<div class="browniefooter">$gbcontent</div>\n$&%;
#      do "mangle/special/use_css.pm"; 
      mangle::special::use_css::mangle();
      # fix AR's non-standard HTML
      s%(<a href)\s*=([a-zA-Z0-9/.:?&\%=-]+)([> ])%$1="$2"$3%g;
   }
   s{http:(//pagead2.googlesyndication.com/pagead/show_ads.js)}{https:$1};
}

1;
