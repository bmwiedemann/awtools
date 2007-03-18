#
# manage bbcode translation for AWtools
#
package bbcode;
use strict;
use warnings;
#use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(bbcode_trans);

sub bbcode_trans($)
{
   local $_=$_[0];
   my $count;
   do {
      $count=0;
      $count+= s/\[([bui])\]([^[]*)\[\/\1\]/<$1>$2<\/$1>/;
      $count+= s/\[(url)\](http:[^<>"[]*)\[\/\1\]/<a href="$2">$2<\/a>/;
      $count+= s/\[(img)\](http:[^<>"[]*)\[\/\1\]/<$1 src="$2" \/>/;
      $count+= s/\[(color)=([a-z_-]+)\]([^[]*)\[\/\1\]/<span style="color:$2;">$3<\/span>/i;
      $count+= s/\[(size)=([0-9.]+)\]([^[]*)\[\/\1\]/<span style="font-size:$2em;">$3<\/span>/i;
   } while($count);
   s/\n/<br>/g;
   return $_;
}

1;
