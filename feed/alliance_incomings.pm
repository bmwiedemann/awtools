my $data=getparsed(\%::options);
my $debug=1;#$::options{debug};
if(1){
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

#open(OUT, ">", "html/x/$ENV{REMOTE_USER}-incomings.html");
#print OUT $_; close OUT;

dbfleetaddinit(undef, 2);

require 'feed/libincoming.pm';
feed::libincoming::parseincomings($_);
feed::libincoming::feedincomings($data->{incoming});
dbfleetaddfinish();
}
1;
