my $debug=$::options{debug};
print "news feed\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

require "input.pm";
my $name=$::options{name};

dbfleetaddinit(undef);

require 'feed/libincoming.pm';
parseincomings($_);
1;
