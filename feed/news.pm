my $debug=$::options{debug};
print "news feed\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";
require "./input.pm";
my $name=$::options{name};

our %data;
tie(%data, "DB_File", $dbname) or print "error accessing DB\n";

require 'feed/libincoming.pm';
parseincomings($_);
1;
