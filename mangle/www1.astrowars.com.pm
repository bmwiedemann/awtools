use awstandard;

my $ret=2;
if($::options{url}=~m%http://www1.astrowars.com/$%) {
	my $forum=getawwwwserver();
   s%(Astro Wars) (Login)%<a href="http://$forum/">$1 2.1</a> $2%;
   s%^%<html><head><title>Greenbird's Astrowars 2.1 Login</title></head> <link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/code/css/awlogin.css"><body>
<p> <a href="http://6bone.informatik.uni-leipzig.de/ipv6/stats/stats.php3"> <img src="http://6bone.informatik.uni-leipzig.de/ipv6/stats/log.php3?URL=aw21.zq1.de&amp;ImageId=5" border="0" width="82" height="34" alt="IPv6-ready"></a> </p>
	%;
   s%$%</body></html>%;
   $ret=1;
}
$ret;
