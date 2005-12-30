my $debug=1;#$::options{debug};
if(1){
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

require "input.pm";

dbfleetaddinit(undef);

require 'feed/libincoming.pm';
parseincomings($_);
dbfleetaddfinish();
}
1;
