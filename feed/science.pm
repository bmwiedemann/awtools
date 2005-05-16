exit 0; # partial energy no more needed

my $debug=$::options{debug};
print "science feed\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
require "./input.pm";
my $name="\L$::options{name}";


my @science;
foreach my $sci (@::sciencestr) {
	if(m!$sci</a> </td><td>(\d+)</td><td><img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"!) {
		my $sl=$1+($2/($2+$3));
#		print "$sci: $sl $1 $2 $3\n<br>";
		push(@science, $sl);
	}
}

our %relation;
tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
my $oldentry=$relation{$name};
my $newentry=addplayerir($oldentry,\@science,undef,undef);
if($debug){ print "$oldentry @science new:$newentry\n<br>" }
else {$relation{$name}=$newentry}
untie %relation;


1;
