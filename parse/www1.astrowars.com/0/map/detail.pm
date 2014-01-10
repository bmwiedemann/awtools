use strict;
use awparser;

my $caption=getcaption($_);
my($sid, $sysname, $sysx, $sysy)=($caption=~m{Planets at ID (\d+) - ([^<]+) \(([-0-9]+)/([-0-9]+)\)});
$d->{sid}=$sid;
$d->{name}=$sysname;
$d->{x}=int($sysx);
$d->{y}=int($sysy);
$d->{bonus}=tobool(m/>Bonus Planets at ID/);

my @planet=();
my $n=10; # debug
parsetable($_, sub {
		my($line,$start, $a)=@_;
		return if $line=~m{ID</th>}; # skip header
		return if $start=~m/class="sysDetailFleet"/; # TODO parse later?
		return if $start=~m/class="sysDetailInco"/; # TODO
		return if($a->[0]<=0 || $a->[0]>12);
		my %p=(
			id=>int($a->[0]),
			population=>int($a->[3]),
			starbase=>int($a->[4]),
			sieged=>tobool($start=~m/^ class="sieged"/),
		);
		my $ownerline=$a->[2];
		if($ownerline=~m{Profile\.php\?id=(\d+)">([^<]+)</a>}) {
			$p{pid}=$1;
			$p{name}=$2;
		}
		push(@planet, \%p);
#		$d->{"x".$n++}="$line --- $start -- ".join(",",@$a);
	});

$d->{planet}=\@planet;

2;
