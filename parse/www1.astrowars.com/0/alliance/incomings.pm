parsetable($_, sub {
		my($line,$start, $a)=@_;
		require parse::libincoming;
		my $inco=parse::libincoming::parse_incoming($line);
}

1;
