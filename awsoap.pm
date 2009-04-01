use strict;

package awsoaphelper;
use LWP::UserAgent ();
use LWP::Simple;
use awstandard;

my $debug=0;

our $UA = LWP::UserAgent->new(requests_redirectable=>[], parse_head=>0, timeout=>9
, agent=>"Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.8.1.21) Gecko/20090309 SUSE/1.1.15-1.1 SeaMonkey/1.1.15");

our %buildingname=();
foreach my $i (0..$#awstandard::buildingstr) {
	$buildingname{$awstandard::buildingstr[$i]}=$awstandard::buildingval[$i];
}

sub randip()
{
	my @ip=(127,int(rand(256)),int(rand(256)),int(rand(256)));
	return join(".", @ip);
}

sub getip()
{
	my $ip=$ENV{REMOTE_ADDR};
	if(awstandard::isproxy($ip) && $ENV{HTTP_X_FORWARDED_FOR}) {
		$ip=$ENV{HTTP_X_FORWARDED_FOR};
	}
	$::fakeip||$ip||randip;
}


sub _do_www1post(%)
{
	my($class,$h)=@_;
	my $method=$h->{method}||"POST";
	my $uri=$h->{uri};
	my $ip=getip;
	if($debug) {
		$uri="http://aw.lsmod.de/cgi-bin/public/testenv?$uri";
	} else {
		$uri="http://aw21.zq1.de$uri";
	}
	my $request = HTTP::Request->new($method, $uri);;
	$request->header("Cookie", "PHPSESSID=$h->{sessionid}");
	$request->header("X-Forwarded-For", $ip);
#	$request->header("User-Agent", $ENV{HTTP_USER_AGENT});
	my $response = $UA->request($request);
#	print $response->content;
	sleep(0.5+rand(3)) if(!$debug);
	return $response;
}


sub myget($)
{
	my ($uri)=@_;
	my $method="GET";
	my $request = HTTP::Request->new($method, $uri);;
	my $response = $UA->request($request);
	if(!defined($response)) { die "is AW down?"}
	return $response;
}

package awsoap;
use JSON::XS;
use Time::HiRes "sleep";

sub do_www1post(%)
{
	my($class,$h)=@_;
	my $response=awsoaphelper::_do_www1post($class,$h);
	if(!defined($response)) { return }
	return $response->content;
}

sub do_www1get(%)
{ $_[1]->{method}="GET"; &do_www1post}

sub getdata(%)
{
	my($class,$h)=@_;
	$h->{uri}="/json$h->{uri}";
	my $jsdata=do_www1get($class,$h);
	if($jsdata!~m/^\{/) {
		return "Error: no JSON data\n$jsdata";
	}
	my $data=decode_json($jsdata);
	return $data;
}

sub htmlencode($)
{
	my $string=$_[1];
	$string=~s/([^a-zA-Z0-9.,+*\/ -])/sprintf("&#%02x;", ord($1))/ge;
	return $string;
}

sub getsoapversion()
{
	return 1;
}

sub getawsessionid($$)
{
	my($class,$user,$pass)=@_;
	my $h={};
	my $uri="http://www1.astrowars.com/register/login.php?user=$user&passwort=$pass";
	$h->{uri}="/register/login.php?user=$user&passwort=$pass";
	my $response=awsoaphelper::myget($uri);
	my $content = $response->content;
	my $location = $response->header("Location");
	my $cookie = $response->header("Set-Cookie");
	my $code=$response->code;
	if($content=~m{<b>(Incorrect password)</b><br><a href=/register/sendpassword.php>} or 
		$content=~m{(Unknown loginname).<br><br></td></tr></table>}
	) {
		return ("Error", $1);
	}
	return "$user+$pass+$code+$location+$cookie\n\n$content";
}

# farm fabrik kultur ... awstandard::buildingval
sub do_building(%)
{
	my($class,$h)=@_;
	my $i=$h->{planet};
	my $p=$h->{building};
	$h->{uri}="/0/Planets/submit.php?points=$h->{pp}&produktion=$p&i=$i";
	do_www1post($class,$h);
}

sub _do_spendsu(%)
{
	my($class,$h)=@_;
	my $i=$h->{planet};
	my $p=$h->{building};
	$h->{uri}="/0/Planets/submit2.php?produktion=$p&i=$i";
	do_www1post($class,$h);
	return 1;
}

sub do_build(%)
{
	my($class,$h)=@_;
	if(!$h->{planet}) {
		local $h->{method}="GET";
		$h->{uri}="/json/0/Planets/";
		my $jsdata=do_www1post($class,$h);
		if($jsdata!~m/^\{/) {
			return "Error: no JSON data\n$jsdata";
		}
		my $data=decode_json($jsdata);
		require awinput;
		awinput::awinput_init(1);
		my $found;
		foreach my $p (@{$data->{planet}}) {
			my $n=$p->{name};
			$n=~s/\s(\d+)$//;
			my $pid=$1;
			next if $pid != $h->{pid};
			my $sid=awinput::systemname2id($n);
			next if $sid != $h->{sid};
			$found=$p;
		}
		awinput::awinput_finish();
		if($found) {
			if($found->{pp}<$h->{pp}) {return "error: can not to build - insufficient PP"}
			$h->{planet}=$found->{id};
		} else {
			return "error: planet not found: $h->{sid}$h->{pid}"
		}
	}
	if(my $b=$buildingname{uc($h->{building})}) {
		$h->{building}=$b;
	}
#	$debug=1;
	$class->do_building($h);
	return 1;
}



sub set_science(%)
{
	my($class,$h)=@_;
	$h->{uri}="/0/Science/submit.php?science=f_$h->{sci}";
	do_www1post($class,$h);
}

1;
