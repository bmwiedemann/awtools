use strict;

my $r=$::options{request};
my $uri=$::options{url};
#$uri=~s{^http://www1\.astrowars\.com/0/json/}{http://www1\.astrowars\.com/0/};
$uri=~s{^http://www1\.astrowars\.com/json/}{http://www1\.astrowars\.com/};
$r->uri($uri);

2; # means go on with normal processing
