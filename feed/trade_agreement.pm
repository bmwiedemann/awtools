use strict;
#my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
#my %relation;
my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}
my $name=$::options{name};
my $data=getparsed(\%::options);

my @a;
my @trade=();
my @tpid=();
foreach my $ta (@{$data->{ta}}) {
	# other status: "request is pending" "establishing trade infrastructure?"
	next if $ta->{status} ne "active trading";
	push(@trade,$ta->{name});
	push(@tpid,$ta->{pid});
}

{
	print " ".a({-href=>"relations?name=$name"},"name=$name").br().join(",",@trade).br();
#	tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
#   $name="\L$name";
#	my $oldentry=$relation{$name};
	dbplayeriradd($name, undef, undef, undef, \@trade);
	awinput::add_trades($::options{pid},\@tpid);
#	if(!$debug) {$relation{$name}=$newentry;}
#	else {print "<br>new:",$newentry;}
}

1;
