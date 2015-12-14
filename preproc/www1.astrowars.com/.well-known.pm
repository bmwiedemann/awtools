# serve letsencrypt ACME challenge files
use strict;
use warnings;
use awstandard;

my $cachedir="$awstandard::htmldir/";

my $u=$::options{url};
return 2 if not $u=~m!https?://([^/]+)(/.*)!;
return 2 if $u=~m/\.\./;
my($domain,$path)=(lc($1),$2); # domain is case-insensitive
$u="$cachedir/$path";
my ($c)=file_content($u);
if($c) {
	my $r=$::options{req}; # apache request obj
	$r->content_type("text/plain");
	$r->set_content_length(length($c));
	$r->print($c);
	return 1;
}
return 2;

