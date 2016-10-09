use strict;

my $r=$::options{request};
my $uri=$::options{url};
$uri=~s{^http://www1\.astrowars\.com/bmw/bahn}{https://reiseauskunft.bahn.de/}; 
$uri=~s{^http://www1\.astrowars\.com/bmw/regen/stats}{http://stats.t-online.de/}; 
$uri=~s{^http://www1\.astrowars\.com/bmw/regen/data}{http://data.wetter.info/}; 
$uri=~s{^http://www1\.astrowars\.com/bmw/regen2/}{http://www.t-online.de/}; 
$uri=~s{^http://www1\.astrowars\.com/bmw/regen/}{http://www.wetter.info/}; 
$uri=~s{^http://www1\.astrowars\.com/bmw/$}{http://www.wetter.com/wetter_aktuell/wettervorhersage/3_tagesvorhersage/deutschland/roethenbach/DE0008533.html};
$r->uri($uri);
$r->header("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0");

2; # means go on with normal processing
