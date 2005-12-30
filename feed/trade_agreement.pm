use strict;
#my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
require "input.pm";
#my %relation;
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

my @a;
my @trade=();
for(;(@a=m!<tr[^>]*><td[^>]*><a [^>]*>([^>]+)</a>.*?</tr>(.*)!); $
_=$a[1]) {
	push(@trade,$1);
}

{
	print " ".a({-href=>"relations?name=$name"},"name=$name").br();
#	tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
#   $name="\L$name";
#	my $oldentry=$relation{$name};
	dbplayeriradd($name, undef, undef, undef, \@trade);
#	if(!$debug) {$relation{$name}=$newentry;}
#	else {print "<br>new:",$newentry;}
}

1;
