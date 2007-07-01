use strict;
use awinput;
use sort_table;

my %transtable=(Biology=>"bio", Economy=>"eco", Energy=>"energy", Mathematics=>"math", Physics=>"physics", Social=>"social");
if($::options{name} && $ENV{REMOTE_USER}) {
   my $etc=awinput::playerid2etc($::options{pid});
   if($etc) {
      $etc=sort_table::display_etc($etc);
      s{(Culture)</a>} {$1</a> in $etc};
   }
}
#http://www1.astrowars.com/0/Science/submit.php?science=f_bio
      sub trans($) {my($sci)=@_;
         my $s=$transtable{$sci};
         return "" if !$s;
         return "<a href=\"submit.php?science=f_$s\" class=\"awtools\">change&nbsp;to</a>&nbsp;";
      }
      s%(<tr align=center bgcolor='#\d+'><td)>(<a href=/0/Glossary[^>]*>)(\w+)%$1." align=left>".trans($3).$2.$3%ge;

my $extrastyle="scitext disabled";
s%("r" class=)text%$1$extrastyle%;
s%("z" class=)text%$1$extrastyle%;


sub calcbonus($$) {
   my($base,$bonus)=@_;
   $bonus||=0;
   return int($base*(1+$bonus/100));
}

s{id=23">\(\+(\d+) per hour\)</a>(?:\s*<b>([+-]\d+)%</b>)?}{"$& = ".calcbonus($1,$2)."/h"}ge;

1;
