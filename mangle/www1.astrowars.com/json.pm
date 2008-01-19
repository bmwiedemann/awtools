use strict;
use JSON::XS;
use parse::dispatch;

my $r=$::options{req};
$::options{url}=~s{^http://www1\.astrowars\.com/json/}{http://www1.astrowars.com/};
if($::options{url}=~s/.debug=1$//) { $::options{debug}=1; }
if($::options{url}=~s/.callback=([a-zA-Z_]\w+)$//) { $::options{callback}=$1; }
my $data=parse::dispatch::dispatch(\%::options);

my $prefix="";
my $postfix="";
if($::options{callback}) {
	$prefix=$::options{callback}."( ";
	$postfix=" );";
}
if(!$::options{debug}) {
	$r->content_type("application/x-javascript");
   $_=$prefix;
	$_.=encode_json($data);
	$_.=$postfix
}
else {
	$_.=JSON::XS->new->utf8->pretty->encode($data);
}

30; # means return our output $_ verbatim
