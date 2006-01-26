# link mail from
s%(>You have new mail from )([^<]+)(.<br><a href)%"$1<a href=/0/Player/Profile.php/?id=".playername2id($2).">$2</a>$3"%ge;

require "mangle/special_color_incomings.pm"; mangle_incoming();

1;
