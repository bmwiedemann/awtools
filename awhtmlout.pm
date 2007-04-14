package awhtmlout;
use strict;
use awstandard;
use awinput;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&mangleplayerlink);

sub mangleplayerlink($$) { my($id,$name)=@_;
   my @rel=getrelation($name);
   my $alli=playerid2pseudotag($id);
   my $col=getrelationclass($rel[0]);
   return $col."\">$alli$name";
}

1;
