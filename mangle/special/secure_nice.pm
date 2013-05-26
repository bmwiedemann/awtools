#!/usr/bin/perl
# special handler (can not work on specific URLs)
use strict;
use warnings;
package mangle::special::secure_nice; 
use vkeyboard;

sub mangle($)
{ 
   local $_=$_[0];
   s%(img src="/0/secure.php" alt="Security Mesasure" width=)"180" width="45"%$1"240" height="60"%;
   my $style="awlogin";
   s%</heads>%</head>%;
#   s%</td></tr></table>%$&</form>%;
   my $vk=vkeyboard("loginSecurity.secure",[0..9,"a".."f"]);
   s%class=smbutton></td></tr>\s*</table>%$&$vk%;
   s/id="secure"/$& autofocus="autofocus"/;

   $_[0]=$_;
}

1;
