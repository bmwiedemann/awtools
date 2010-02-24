# add Rasta link
s{Best Planets</b>}{$& <a href="http://www.astrowars-tools.com/rankings.php?ranking=bestPlanets" class="awtools">Rasta</a>};


s%(<tr bgcolor="#262626" align=center><td>\d+</td><td>)(<a href=/about/starmap.php\?dx=)([+-]?\d+)&dy=([+-]?\d+)>([^<]*</a></td>)%$1."<a href=\"/0/Map/Detail.php/?nr=".systemcoord2id($3,$4)."\">s</a> ".$2.$3."&dy=".$4.">".$5%ge;

# add Total column:
s{<td>Owner</td>}{<td>Total</td>$&};
s{<tr bgcolor="#262626" align=center><td>\d+</td><td>.*?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>}{"$&<td>".($1+$2+$3+$4)."</td>"}ge;


2; # mangle on upwards
