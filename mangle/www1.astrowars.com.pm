use awstandard;

my $ret=2;
if($::options{url}=~m%http://www1.astrowars.com/$%) {
	my $forum=getawwwwserver();
   s%(Astro Wars) (Login)%<a href="//$forum/">$1 2.1</a> $2%;
   s%^%<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	"http://www.w3.org/TR/html4/loose.dtd"><html><head><title>Greenbird's Astrowars 2.1 Login</title><link rel="stylesheet" type="text/css" href="/code/css/awlogin.css"><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link rel="canonical" href="http://$awserver/" >
	</head><body>
<p> <a href="https://6bone.informatik.uni-leipzig.de/ipv6/stats/stats.php3"> <img src="https://6bone.informatik.uni-leipzig.de/ipv6/stats/log.php3?URL=aw21.zq1.de&amp;ImageId=5" border="0" width="82" height="34" alt="IPv6-ready" /></a> </p>
<a href="https://flattr.com/thing/326749/greenbirds-AWTools" target="_blank">
<img src="https://button.flattr.com/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a><br>
<a href="//$bmwserver/">AWTools</a><br>

	%;
	s%&passwor%&amp;passwor%;
   s%$%</body></html>%;
   $ret=1;
}
$ret;
