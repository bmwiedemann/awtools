package mangle::special::color;
use strict;
use awstandard;
use awinput;
use awhtmlout;

sub mangle() {
# colorize player links
#   s%(<a href=/about/playerprofile\.php\?id=)(\d+)>([^<]*)</a>%"<a href=\"/0/Player/Profile.php?id=$2\">p</a> ".$1.$2." class=\"".mangleplayerlink($2,$3)."</a>"%ge;
   s%(<a href=/0/Player/Profile\.php/?\?id=)(\d+)>([^<]*)</a>%$1.$2." class=\"".mangleplayerlink($2,$3)."</a>"%ge;
   s%(<a href="profile\.php\?mode=viewprofile&amp;u=)(\d+)([^>]*?)(?:class="name")?>([^<]*)</a>%$1.$2.$3." class=\"".mangleplayerlink($2,$4)."</a>"%ge;
   s%<a href\s*=("?)/0/Glossary/%<a class="awglossary" href=$1/0/Glossary/%g;
   s%<a( href="../Glossary/)%<a class="awglossary"$1%g;
}

1;
