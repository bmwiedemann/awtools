
$_="# brownie override to prevent crawlers from indexing everything multiple times
User-agent: *
#Disallow: /
Disallow: /images/
Disallow: /data/
Disallow: /stats/
Disallow: /about/
Disallow: /register/
Disallow: /forums/
Disallow: /portal/
Disallow: /chat/
Disallow: /rankings/
Disallow: /wiki/
";

if($::options{url}!~m{^http://www.aw21.zq1.de/}) {
#	s/#D/D/;
#	$_.=$url;
#	my @a=%::options;
#	$_.="@a";
}

1;
