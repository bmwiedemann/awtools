use Apache2::Const -compile => qw(REDIRECT);

# as per request from AllesRoger 2013-11-16
# "Ich will nicht das Forum über einen Proxy läuft."
if($::options{proxy} eq "brownie21") {
	my $r=$::options{req}; # apache request obj
	$r->headers_out->set('Location' => $::options{url});
	$r->status(Apache2::Const::REDIRECT);
	return 1;
}

return 2;
