# add Rasta link
s{Best Planets</b>}{$& <a href="http://www.astrowars-tools.com/rankings.php?ranking=bestPlanets" class="awtools">Rasta</a>};


# add Total column:
s{<td>Owner</td>}{<td>Total</td>$&};
s{<tr bgcolor="#262626" align=center><td>\d+</td><td>.*?</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>}{"$&<td>".($1+$2+$3+$4)."</td>"}ge;


# mangle on upwards
do "mangle/www1.astrowars.com/rankings/_coord2sys.pm";
