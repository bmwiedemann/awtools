
# add Rasta link
s{<b>Strongest available Fleet</b>}{$& <a href="http://www.astrowars-tools.com/rankings.php?ranking=bestFleets" class="awtools">Rasta</a>};

# add CV column:
s{<td>Owner</td>}{<td><a href="http://www.astrowars.com/portal/CV">CV</a></td>$&};
s{<tr bgcolor="#262626" align=center><td>\d+</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>}{"$&<td>".(($1+$2*8+$3*20)*3)."</td>"}ge;

2;
