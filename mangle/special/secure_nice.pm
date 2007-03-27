#!/usr/bin/perl
# special handler (can not work on specific URLs)
use strict;
use warnings;
package mangle::special::secure_nice; 

sub mangle($)
{ 
   local $_=$_[0];
   s%(img src="/0/secure.php" width=)"120" width="30"%$1"240" height="60"%;
   $_[0]=$_;
}

1;
