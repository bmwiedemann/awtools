package mangle::dispatch;
use strict;
use awstandard;
use awinput;

$::bmwlink="<a href=\"http://$bmwserver/cgi-bin";

sub manglefilter { 
   my $gameuri=defined($::options{url}) && $::options{url}=~m%^http://www1\.astrowars\.com/%;
   my $ingameuri=$gameuri && $::options{url}=~m%^http://www1\.astrowars\.com/0/%;
   my $title="";
   my $module="";
   my $alli="\U$ENV{REMOTE_USER}";
   if($gameuri && m&<title>([^<]*)</title>&) {
      $title=$1;
      $module=title2pm($title);
      my $include="mangle/$module.pm";
      if(-e $include) {
         do $include;
         if($@) {$module="error in $module: $@";}
         else { $module="mangling applied: $module"; # for the log
         }
      }
      else {$module="no special mangling for: $module"}
      $module=qq'<p style="color:gray">$module</p>';

# add main AWTool link
      if($ingameuri && (my $session=${$::options{headers}}{Cookie})) {
         $session=~s/^.*PHPSESSID=([^; ]*).*/$1/;
         my $bsid=pack("H*",$session);
         #$bsid =~ s/([0-9a-fA-F][0-9a-fA-F])/pack("c",hex($1))/eg;
         my %sessions;
         tie %sessions,'Tie::DBI',$DBAccess::dbh, 'usersession', 'sessionid',{CLOBBER=>1};
         my $s=$sessions{$bsid};
         if(!$s) {
            $s={"sessionid"=>$bsid, "name"=>$::options{name}, "nclick"=>0, "firstclick"=>time()};
         }
         my $nclicks=$$s{nclick}+1;
         $$s{nclick}=$nclicks;
         $$s{lastclick}=time();
         $sessions{$bsid}=$s;
         if($nclicks>290) {$nclicks=qq'<b style="color:#f44">$nclicks</b>'}
         s%Fleet</a></td>%$&<td>|</td><td>$::bmwlink/index.html">AWTools</a> $nclicks</td>%;
#         $::bmwlink/authaw?session=$session">AWTools...
      }

# colorize player links
      require "mangle/color.pm"; mangle_player_color();

   }

# remove ads
   s/<table><tr><td><table bgcolor="#\d+" style="cursor: pointer;".*//;
# disable ad
   s/(?:pagead2\.googlesyndication\.com)|(?:games\.advertbox\.com)|(?:oz\.valueclick\.com)|(?:optimize\.doubleclick\.net)/localhost/g;

# add disclaimer
   if(!$alli) {$alli=qq!<b style="color:red">no</b>!}
   s%</body>%</center>disclaimer: this page was mangled by greenbird's code (for $::options{name} in context of $alli alliance data). <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again. $module $&%;

   s%<br>\s*(<TABLE)%$1%;
}

sub mangle_dispatch(%) { my($options)=@_;
   %::options=%$options;
   if(!$::options{url} || $::options{url}!~m%/images/%) {
      manglefilter();
   }
}

1;
