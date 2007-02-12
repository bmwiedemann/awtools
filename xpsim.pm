# XP simulator - heavily inspired by Moaltz's code

package xpsim;
use strict;
use warnings;
use awstandard;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT =
qw(&daysbonus &xpsim &xpsim_print);

sub daysbonus($$) { my($bonus,$days)=@_;
   my $base=1+($bonus+12)*0.001;
   return (($base**$days)**2.7);
}

# input: bonus between -12 and 12
# input: array with [XP and bonus-days]
# output: XP on last day of sim
sub xpsim_internal2($@)
{ my($bonus,$xp)=@_;
   my $base=1+($bonus+12)*0.001;
   my $sum=0;
   foreach my $e (@$xp) {
      $sum+=$e->[0]*(($base**$e->[1])**2.7);
# xp:=xp*((base^days)^2.7)
# derived from original
# pl:=pl*(base^days)
   }
   return $sum;
}

sub xpsim_internal(@)
{ my ($a)=@_;
   my @xp; # contains arrayref[ XP,number of days of bonus]
   {
      my $d=0; # stores number of days in the past
      for(my $i=@$a-1; $i>=0; $i-=2) {
         my ($xpref,$ddiff)=(@$a[$i-1,$i]);
         $d+=$ddiff;
         foreach my $x (@$xpref) {
            push(@xp, [$x,$d]);
         }
      }
   }
   my @totalxp;
   foreach my $bonus (-12..12) {
      my $xp=xpsim_internal2($bonus, \@xp);
      push(@totalxp,[$bonus,$xp]);
   }
   return \@totalxp
}

sub xpsim($) { my ($str)=@_;
   $str=~s/[^0-9,.\[\]]//g;
   my $ret=eval("xpsim_internal([".$str."])");
   if($@) {print $@; return undef;}
   return $ret;
}

sub xpsim_print($) { my ($str)=@_;
   my $ret=xpsim($str);
   return if not $ret;
   foreach my $e (@$ret) {
      my ($bonus,$xp)=@$e;
      printf("%+3i PL=%.2f\n", $bonus, int(100*awstandard::awxp2pl($xp))/100);
   }
}

1;
