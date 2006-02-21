s%<td><a href="?/rankings/alliances/([a-zA-Z]+)\.php"?>%$& [$1] %g;
# breaks for single player NAPs:
#s%(Type</td>)(<td>Name)%$1 <td>Tag</td>$2%;
#s%<td><a href="?/rankings/alliances/([a-zA-Z]+)\.php"?>%<td>$1</td>$&%g;
2;
