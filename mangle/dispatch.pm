use strict;

our $bmwlink=qq%<a href="http://$::bmwserver/cgi-bin%;

sub manglefilter { my($urlarg)=@_;
   my $title="";
#   my $urlarg2=lc($urlarg);
#   $urlarg2=~s/\?.*//;
#   $urlarg2=~s/(?:\.php)?\/*$//;
#   $urlarg2=~s/\//_/g;
   my $module="";
   if(m&<title>([^<]*)</title>&) {
      $title=$1;
      $module=title2pm($title);
      my $include="mangle/$module.pm";
      if(-e $include) {
         require $include;
         $module="<br>mangling applied: $module"; # for the log
      }
      else {$module="<br>no special mangling for: $module"}

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
   s%</body>%disclaimer: this page was mangled by greenbird's code. <br>This means that errors in display or functionality might not exist in the original page. <br>If you are unsure, disable mangling and try again. $module $&%;

   s%<br>\s*(<TABLE)%$1%;
}



if($::options{url}!~m%/images/% && $::options{url}=~/www1\.astrowars\.com\/0\/(.*)/) {
   manglefilter($1);
}

1;
