use awinput;
use awhtmlout;

s%(<a href=/about/playerprofile\.php\?id=)(\d+)>([^<]*)</a>%"<a href=\"/0/Player/Profile.php?id=$2\">p</a> ".$1.$2." class=\"".mangleplayerlink($2,$3)."</a>"%ge;

1;
