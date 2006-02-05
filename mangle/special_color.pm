package mangle::special_color;
use awstandard;
use awinput;

sub manglecolor($$) { my($id,$name)=@_;
   my $col="white";
   my @rel=getrelation($name);
   my $alli="";
   my $atag=playerid2tag($id);
   if($atag) {$alli="[$atag] "}
   elsif($rel[1] && $id>2) {$alli="[$rel[1]] "}
   if($rel[0]) {
      $col=getrelationcolor($rel[0]);
   }
   return $col."\">$alli$name";
}

sub mangle_player_color() {
# colorize player links
   s%(<a href=/0/Player/Profile\.php/?\?id=)(\d+)>([^<]*)</a>%$1.$2." style=\"color:".manglecolor($2,$3)."</a>"%ge;
   s%(<a href="profile\.php\?mode=viewprofile&amp;u=)(\d+)("[^>]*)>([^<]*)</a>%$1.$2.$3." style=\"color:".manglecolor($2,$4)."</a>"%ge;
}

1;
