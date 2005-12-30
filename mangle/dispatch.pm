use strict;

our $bmwlink=qq%<a href="http://$::bmwserver/cgi-bin%;

sub manglefilter { 
   my $title="";
   my $module="";
   if(m&<title>([^<]*)</title>&) {
      $title=$1;
      $module=title2pm($title);
      my $include="mangle/$module.pm";
      if(-e $include) {
         require $include;
         $module="mangling applied: $module"; # for the log
      }
      else {$module="no special mangling for: $module"}
      $module=qq'<p style="color:gray">$module</p>';

# add main AWTool link
      s%Fleet</a></td>%$&<td>|</td><td><a href="http://$::bmwserver/cgi-bin/index.html">AWTools</a></td>%;

# colorize player links
      require "./mangle/color.pm";

   }

# remove ads
   s/<table><tr><td><table bgcolor="#\d+" style="cursor: pointer;".*//;
# disable ad
   s/pagead2.googlesyndication.com/localhost/g;

# add disclaimer
   s%</body>%</center>disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again. $module $&%;

   s%<br>\s*(<TABLE)%$1%;
}



if($::options{url}!~m%/images/%) {
   manglefilter();
}

1;
