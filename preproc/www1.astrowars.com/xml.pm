use strict;

my $r=$::options{request};
my $uri=$::options{url};
$uri=~s{^http://www1\.astrowars\.com/xml/}{http://www1\.astrowars\.com/};
$r->uri($uri);

2; # means go on with normal processing
