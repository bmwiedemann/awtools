use awparser;
use awinput;
use model::bestguarded;

my $d=getparsed(\%::options);
foreach my $p (@{$d->{planet}}) {
	my $cv=$p->{cv};
	my $l=$p->{location};
	my $sid=systemcoord2id($l->{x}, $l->{y});
	print "$sid $l->{pid} $cv<br>";
	model::bestguarded::add($sid, $l->{pid}, $cv);
}

1;
