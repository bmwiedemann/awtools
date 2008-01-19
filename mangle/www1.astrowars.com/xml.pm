use strict;
use XML::Simple;
use parse::dispatch;

my $r=$::options{req};
$::options{url}=~s{^http://www1\.astrowars\.com/xml/}{http://www1.astrowars.com/};
if($::options{url}=~s/.debug=1$//) { $::options{debug}=1; }
my $data=parse::dispatch::dispatch(\%::options);

if(!$::options{debug}) {
	$r->content_type("text/xml");
   $_="";
}
$_.=XMLout($data);

30; # means return our output $_ verbatim
