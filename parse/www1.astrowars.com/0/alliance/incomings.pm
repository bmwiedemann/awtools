require parse::libincoming;
parsetable($_, sub {
		my($line,$start, $a)=@_;
		my $inco=parse::libincoming::parse_incoming($line);
		push(@{$d->{incoming}}, $inco) if $inco;
		#$d->{debug}=$line unless $inco;
});

1;
