use strict;
use JSON::XS;
use parse::dispatch;

$::options{url}=~s{^http://www1\.astrowars\.com/json/}{http://www1\.astrowars\.com/};
my $data=parse::dispatch::dispatch(\%::options);

$_=encode_json($data);
#$_.=" json mangling OK";

30; # means return our output $_ verbatim
