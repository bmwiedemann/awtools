sub manglecolor($) { my($name)=@_;
   my $col="white";
   my @rel=getrelation($name);
   my $atag="";
   if($rel[0]) {
      $col=getrelationcolor($rel[0]);
   }
   if($rel[1]) {
      $atag=" [$rel[1]]";
   }
   return $col."\">$name$atag";
}

# colorize player links
   s%(<a href=/0/Player/Profile.php/?\?id=)(\d+)>([^<]*)</a>%$1.$2." style=\"color:".manglecolor($3)."</a>"%ge;

1;
