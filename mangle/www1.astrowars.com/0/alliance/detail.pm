use strict;
use awinput;

# add system ID tool links
s%(<tr align=center bgcolor=#\d+><td[^>]*>)(\d+)(</td><td)%$1$::bmwlink/system-info?id=$2">$2</a>$3%g;

# add next and prev buttons
if($::options{url}=~/id=(\d+)/) {
   my $id=$1;
   my $url="?id=";

   while(1) { # pseudo loop to exit at several places
      my $user=$::options{name};
      my $pid=playername2id($user);
      last unless($pid && $pid>2);
      my $aid=lc(playerid2alliance($pid));
      last unless($aid);
      my $members=awinput::allianceid2membersr($aid);

      my $previd=$id-1;
      my $nextid=$id+1;
      my $prevstring="";

      s%([^<>]*)(<br><table border=0)%
         my $id=playername2id($1);
         my $x=$1;
         if($id) { $x="<a href=\"/0/Player/Profile.php/?id=$id\">$1</a>"; }
         $x.$2%e;
      if($previd>=0) { $prevstring.=qq'<a href="$url$previd">prev</a>'; }
      if($nextid<@$members) { $prevstring.=qq' <a href="$url$nextid">next</a>'; }
      my $form="";
      my $n=0;
      $form.=' <form action=""><select style="text-align:left;" name="id" onchange="submit()">';
      foreach my $m (@$members) {
         my $name=playerid2name($m);
         my $sel=($id == $n)?" selected":"";
         $form.=qq' <option value="$n"$sel>$name</option>';
         $n++;
      }
      $form.='</select><input type="submit" class="smbutton" value="Go"></form> ';
   
      s%<br><table border=0%<br>$prevstring$form$&%;
      last;
   }
   do "mangle/www1.astrowars.com/0/alliance.pm";
}

# add classes - but not for main_inner table:
my $n=1;
s%<table border=0 cellpadding=1 cellspacing=1 width=600(?=>)%$&.' class="sub_inner" id="alliance_detail'.($n++).'"'%ge;

require "mangle/special/color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();

1;
