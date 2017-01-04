# serve letsencrypt ACME challenge files
use strict;
use warnings;
use awstandard;

my $cachedir="$awstandard::htmldir/";

my $u=$::options{url};
return 2 if $u=~m/\.\./;
return 2 if not $u=~m!https?://([^/]+)(/.*)!;
my($domain,$path)=(lc($1),$2); # domain is case-insensitive
$u="$cachedir/$path";
my ($c)=file_content($u);
my $r=$::options{req}; # apache request obj
if($c) {
	$r->content_type("text/html");
	$r->set_content_length(length($c));
	$r->print($c);
	return 1;
}
$r->content_type("text/plain");
$r->print($u);

return 1;

