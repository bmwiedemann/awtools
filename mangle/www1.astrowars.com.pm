my $ret=2;
if($::options{url}=~m%http://www1.astrowars.com/$%) {
   s%(Astro Wars) (Login)%$1 2.1 $2%;
   s%^%<html><head><title>Greenbird's Astrowars 2.1 Login</title></head> <link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/code/css/awlogin.css"><body>
<p> <a href="http://6bone.informatik.uni-leipzig.de/ipv6/stats/stats.php3"> <img src="http://6bone.informatik.uni-leipzig.de/ipv6/stats/log.php3?URL=www.zq1.de&ImageId=5" border="0"></a> </p>
	%;
   s%$%</body></html>%;
   $ret=1;
}
$ret;
