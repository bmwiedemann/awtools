use strict;
my %transtable=(Biology=>"bio", Economy=>"eco", Energy=>"energy", Mathematics=>"math", Physics=>"physics", Social=>"social");
if(1||$::options{name} eq "greenbird") {
#http://www1.astrowars.com/0/Science/submit.php?science=f_bio
      sub trans($) {my($sci)=@_;
         my $s=$transtable{$sci};
         return "" if !$s;
         return "<a href=\"submit.php?science=f_$s\" class=\"awtools\">change to</a> ";
      }
#      s%(<tr align=center bgcolor="#202060">)(<td></td><td>lvl)%$1<td>chg</td>$2%;
      s%(<tr align=center bgcolor='#\d+'><td)>(<a href=/0/Glossary[^>]*>)(\w+)%$1." align=left>".trans($3).$2.$3%ge;
}

1;
