use strict;

my $r=$::options{request};
my $uri=$::options{url};
$uri=~s{\?(.*)}{};
my $params=$1;
if($params && $::options{request}->method() eq "GET") {
	$r->uri($uri);
	$::options{request}->method("POST");
	$::options{request}->content($params);
#	$::options{request}->header("Content-Length", length($params));
	$::options{request}->header("Content-Type", "application/x-www-form-urlencoded");
}

2;
