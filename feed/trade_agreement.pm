use strict;
my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
use DB_File;
#require "standard.pm";
my %relation;
my %timevalue=(second=>1, minute=>60, hour=>3600, day=>86400);
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};

print "trade agreements feed<br>\n";

my @a;
my @trade=();
for(;(@a=m!<tr[^>]*><td[^>]*><a [^>]*>([^>]+)</a>.*?</tr>(.*)!); $
_=$a[1]) {
	push(@trade,$1);
}

{
	print qq! <a href="relations?name=$name">name=$name</a><br>\n!;
	tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
	$name="\L$name";
	my $oldentry=$relation{$name};
	my $newentry=addplayerir($oldentry, undef, undef, undef, \@trade);
	if(!$debug) {$relation{$name}=$newentry;}
	else {print "<br>new:",$newentry;}
}

1;
