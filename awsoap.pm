use strict;

package awsoaphelper;
use LWP::UserAgent ();
use LWP::Simple;
use awstandard;

our $debug=0;

our $UA = LWP::UserAgent->new(requests_redirectable=>[], parse_head=>0, timeout=>9
, agent=>"Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.8.1.21) Gecko/20090309 SUSE/1.1.15-1.1 SeaMonkey/1.1.15");


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
	$ip||randip;
}


sub _do_www1post(%)
{
	my($class,$h)=@_;
	my $method=uc($h->{method})||"POST";
	my $uri=$h->{uri};
	my $content;
	if(0 && $method eq "POST") { # disabled for now
		# fill body for post requests
		if($uri=~s/\?(.*)$//) {
			$content=$1;
		}
	}

	my $ip=$h->{sourceip} || getip;
	if($debug) {
		$uri="http://aw.lsmod.de/cgi-bin/public/testenv?$uri";
	} else {
		#$uri="http://aw21.zq1.de$uri";
		$uri="http://aw21.uml11b.zq1.de:11080$uri";
	}
	my $request = HTTP::Request->new($method, $uri);;
	if($h->{sessionid}) {
		$request->header("Cookie", "PHPSESSID=$h->{sessionid}");
	}
	$request->header("X-Forwarded-For", $ip);
#	$request->header("User-Agent", $ENV{HTTP_USER_AGENT});
	if(defined($content)) {
		$request->content_type('application/x-www-form-urlencoded');
		$request->content($content);
	}
	my $response = $UA->request($request);
#	print $response->content;
	sleep(0.5+rand(3)) if(!$debug);
	return $response;
}

package awsoap;
use JSON::XS;
use Time::HiRes "sleep";

our %buildingname=();
# init
foreach my $i (0..$#awstandard::buildingstr) {
	$buildingname{$awstandard::buildingstr[$i]}=$awstandard::buildingval[$i];
}



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
	$string=~s/([^a-zA-Z0-9.,+*\/_= -])/sprintf("&#%02x;", ord($1))/ge;
	return $string;
}

sub getsoapversion()
{
	return 1;
}

sub complete_nonpremium_login(%)
{
	my($class,$h)=@_;
	$h->{uri}||="/0/News/";
	my $content=$class->do_www1get($h);
	if($content=~m{<a href="/0/secure.php">Security Measure</a>}) {
		# TODO
		my $origuri=$h->{uri};
		$h->{uri}="/3/secure.php";
		my $n=2;
		my $xxxxx="";
		while($n-->0) {
			$xxxxx=$class->do_www1get($h);
			if($xxxxx=~m/^[0-9a-f]{5}$/) {
				$h->{method}="POST";
				$h->{uri}="$origuri?secure=$xxxxx&submit2=submit";
				sleep 2;
				$class->do_www1post($h);
				return 1;
			}
		}
		return ("Error", "could not read security code: $xxxxx");
	}
	return ("did not ask for it");
}

sub getawsessionid(%)
{
	my($class,$h)=@_;
	my $user=$h->{user};
	my $pass=$h->{pass};
#	my $uri="http://www1.astrowars.com/register/login.php?user=$user&passwort=$pass";
	$h->{uri}="/register/login.php?user=$user&passwort=$pass";
	my $response=$class->awsoaphelper::_do_www1post($h);
	if(!$response) {return ("Error", "AW Server down?");}
	my $content = $response->content;
#	my $location = $response->header("Location");
	my $cookie = $response->header("Set-Cookie");
	my $code=$response->code;
	if($content=~m{<b>(Incorrect password)</b><br><a href=/register/sendpassword.php>} or 
		$content=~m{(Unknown loginname).<br><br></td></tr></table>}
	) {
		return ("Error", $1);
	}
	if($content!~m{<meta http-equiv="refresh" content="0; URL=.*<body bgcolor="#000000">}) {
		return ("Error", $content);
	}
	my $sessionid=$h->{sessionid};
	if($cookie=~m/PHPSESSID=([a-f0-9]+)/) {
		$sessionid=$1;
	}
	if($h->{full}) {
		$h->{sessionid}=$sessionid;
		$h->{uri}="";
		$class->complete_nonpremium_login($h);
	}
#	return "$code+$sessionid+$cookie\n\n$content";
	return ($sessionid);
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


# farm fabrik kultur ... awstandard::buildingval
sub do_building(%)
{
	my($class,$h)=@_;
	my $i=$h->{planet};
	my $p=$h->{building};
	$h->{uri}="/0/Planets/submit.php?points=$h->{pp}&produktion=$p&i=$i";
	do_www1post($class,$h);
}

sub do_build(%)
{
	my($class,$h)=@_;
	if(!defined($h->{planet})) {
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
	return 1;
}

sub do_launch(%)
{
	my($class,$h)=@_;
	for my $f (qw(trn cls ds cs bs)) {
		$h->{$f}||=0;
	}
	my $calc="";
	if($h->{calc}) { $calc="&calc=1" }
	$h->{uri}="/0/Fleet/send.php?inf=$h->{trn}&col=$h->{cls}&des=$h->{ds}&cru=$h->{cs}&bat=$h->{bs}&destination=$h->{dsid}&planet=$h->{dpid}$calc&id=$h->{spid}&nr=$h->{ssid}";
#/0/Fleet/send.php?inf=0&col=3&des=0&cru=0&bat=0&destination=1909&planet=7&calc=1&id=8&nr=1909
	$_=do_www1post($class,$h);
	if(m/ reftime\[1\] = (\d+)/) { # brownie-specific
		$_=$1;
	}
	if(m/ successfully (launched)\.<\/b>/) {
		$_=$1;
	}
	if(m/Please (verify) your submission/) {
		$_=$1;
	}
	return htmlencode($_);
}

sub _qty_str($)
{ my $q=shift;
	if($q!~s{^(.*)/}{q$1}) {
		$q.="qty"; # su/pro
	}
	return $q;
}

sub do_buy(%)
{
	my($class,$h)=@_;
	my $q=_qty_str($h->{buy});
	$h->{uri}="/0/Trade/submit.php?buy=$h->{buy}&$q=$h->{q}";
	do_www1post($class,$h);
	return 1;
}

sub do_sell(%)
{
	my($class,$h)=@_;
	my $q=_qty_str($h->{buy});
	$h->{uri}="/0/Trade/submit2.php?buy=$h->{buy}&$q=$h->{q}";
	do_www1post($class,$h);
	return 1;
}

# artifact 0/0=none 3/5=CR3
sub set_artifact(%)
{
	my($class,$h)=@_;
	$h->{uri}="/0/Trade/submit3.php?buy=$h->{arti}";
	do_www1post($class,$h);
	return 1;
}

sub do_offer_trade(%)
{
	return "TODO find uri";
}


1;
