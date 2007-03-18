my $ret=2;
if($::options{url}=~m%http://www1.astrowars.com/$%) {
   s%(Astro Wars) (Login)%$1 2.1 $2%;
   s%^%<html><head><title>Greenbird's Astrowars 2.1 Login</title></head> <link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/code/css/awlogin.css"><body>%;
   s%$%</body></html>%;
   $ret=1;
}
$ret;
