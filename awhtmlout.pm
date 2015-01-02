package awhtmlout;
use strict;
use CGI ":standard";

use awstandard;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&mangleplayerlink ir2string);

sub mangleplayerlink($$) { my($id,$name)=@_;
   my @rel=getrelation($name);
   my $alli=playerid2pseudotag($id);
   my $col=getrelationclass($rel[0]);
   return $col."\">$alli$name";
}

sub ir2string(@@) {
   my($race,$sci)=@_;
   my ($string,$string2)=("","");
   if($race && defined($race->[0])) {
      my @race=@$race;
      my $currace=pop(@race);
      my $sul=pop(@race);
      my $trader=pop(@race);
      my $sum=pop(@race);
      my $n=0;
      foreach(@race) {
         my $bonus=$awstandard::racebonus[$n]*100*$_;
         if($n==4) {$bonus=$awstandard::speedtable[4+$_];$string.="+${bonus}h $awstandard::racestr[$n++] ($_)".br; next}
         if($bonus>=0) {$bonus="+".$bonus}
         $string.="$bonus% $awstandard::racestr[$n++] ($_)".br;
      }
      if($trader) {$string.= "Trader".br;}
      if($sul) {$string.= "Start Up Lab".br;}
      if(!$currace) {
         $string="<span style=\"color:gray\">$string</span>";
      }
   }
   if($sci && $sci->[0]) {
      my $n=0;
      foreach(@{$sci}[1..$#$sci]) {
         $string2.= "$awstandard::sciencestr[$n++] $_\n".br;
      }
   }
   return ($string,$string2);
}

1;
