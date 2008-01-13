use strict;
use JSON::XS;
use parse::dispatch;

$::options{url}=~s{^http://www1\.astrowars\.com/json/}{http://www1.astrowars.com/};
if($::options{url}=~s/.debug=1$//) { $::options{debug}=1; }
my $data=parse::dispatch::dispatch(\%::options);

if(!$::options{debug}) {
   $_="";
	$_.=encode_json($data);
}
else {
	$_.=JSON::XS->new->utf8->pretty->encode($data);
}

30; # means return our output $_ verbatim
