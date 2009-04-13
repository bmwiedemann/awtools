#
# create js visual keyboard with brownie for AW
#
package vkeyboard;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(vkeyboard);

# input: name of DOM element in JS e.g. "login.secure" for document.login.secure.value
# input: array ref of supported characters
# output: HTML string
sub vkeyboard($@)
{
   my($tname, $a)=@_;
   my $out=q!<span class="vkhidden" onMouseOver="this.className='vkunhidden'" onClick="this.className='vkunhidden'">vk !;
# onMouseOut="this.className='vkhidden'">vk !;
   foreach my $c (@$a) {
      $out.=qq!<input type="button" class="vkbutton" value="$c" onclick="document.$tname.value+= '$c';">!;
   }
   $out.=qq!<input type="button" class="vkbutton" value="&#8701;" onclick="document.$tname.value= '';">!;
   $out.="</span>";
   return $out;
}

1;
