if($::options{url}=~m%http://www1.astrowars.com/$%) {
   s%^%<html><head><title>Greenbird's Astrowars 2.0 Login</title></head> <link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/aw.css"><body>%;
   s%$%</body></html>%;
}
         
1;
