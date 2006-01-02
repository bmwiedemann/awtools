sub manglecolor($$) { my($id,$name)=@_;
   my $col="white";
   my @rel=getrelation($name);
   my $alli="";
   my $atag=playerid2tag($id);
   if($atag) {$alli="[$atag] "}
   elsif($rel[1]) {$alli="[$rel[1]] "}
   if($rel[0]) {
      $col=getrelationcolor($rel[0]);
   }
   return $col."\">$alli$name";
}

# colorize player links
   s%(<a href=/0/Player/Profile.php/?\?id=)(\d+)>([^<]*)</a>%$1.$2." style=\"color:".manglecolor($2,$3)."</a>"%ge;

1;
