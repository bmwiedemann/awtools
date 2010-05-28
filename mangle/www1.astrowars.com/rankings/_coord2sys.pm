
s%(<tr bgcolor="#262626" align=center><td>\d+</td><td>)(<a href=/about/starmap.php\?dx=)([+-]?\d+)&dy=([+-]?\d+)>([^<]*</a></td>)%$1."<a href=\"/0/Map/Detail.php/?nr=".systemcoord2id($3,$4)."\">s</a> ".$2.$3."&dy=".$4.">".$5%ge;

2;

