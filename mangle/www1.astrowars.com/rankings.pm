use awinput;
use awhtmlout;

s%(<a href=/about/playerprofile\.php\?id=)(\d+)>([^<]*)</a>%"<a href=\"/0/Player/Profile.php/?id=$2\">p</a> ".$1.$2." class=\"".mangleplayerlink($2,$3)."</a>"%ge;
s%(<a href="/about/playerprofile\.php\?id=)(\d+)">([^<]*)</a>%"<a href=\"/0/Player/Profile.php/?id=$2\">p</a> ".$1.$2."\" class=\"".mangleplayerlink($2,$3)."</a>"%ge;

s%</head>%<link rel="stylesheet" type="text/css" href="//aw.zq1.de/code/css/main.css">$&%;
if($::options{url}=~m%^http://www1\.astrowars\.com/rankings/$%) {
	s{days wins the game.<br>}{$&<a class="awtools" href="//aw.zq1.de/cgi-bin/public/awstatistics">more alliance rankings</a><br>};
	s{Since beta 5\.}{$&<br><a class="awtools" href="//$awstandard::bmwserver/cgi-bin/public/permanentranking">Permanent Alliance Highscore</a><br><br>};
	s{^</td></tr>$}{$&<tr><td><a class="awtools" href="http://www.astrowars-tools.com/rankings.php">Rasta's Rankings</a></td></tr>}m;
}

1;
