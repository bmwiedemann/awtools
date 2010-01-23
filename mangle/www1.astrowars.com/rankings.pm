use awinput;
use awhtmlout;

s%(<a href=/about/playerprofile\.php\?id=)(\d+)>([^<]*)</a>%"<a href=\"/0/Player/Profile.php/?id=$2\">p</a> ".$1.$2." class=\"".mangleplayerlink($2,$3)."</a>"%ge;

if($::options{url}=~m%^http://www1\.astrowars\.com/rankings/$%) {
	s{days wins the game.<br>}{$&<a class="awtools" href="http://aw.lsmod.de/cgi-bin/awstatistics">more alliance rankings</a><br>};
	s{Since beta 5\.}{$&<br><a class="awtools" href="http://$awstandard::bmwserver/cgi-bin/permanentranking">Permanent Alliance Highscore</a><br><br>};
	s{^</td></tr>$}{$&<tr><td><a class="awtools" href="http://www.astrowars-tools.com/rankings.php">Rasta's Rankings</a></td></tr>}m;
}

1;
