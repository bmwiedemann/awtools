my $debug=1;#$::options{debug};
if(1){
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

#open(OUT, ">", "html/x/$ENV{REMOTE_USER}-incomings.html");
#print OUT $_; close OUT;

dbfleetaddinit(undef);

require 'feed/libincoming.pm';
parseincomings($_);
dbfleetaddfinish();
}
1;
