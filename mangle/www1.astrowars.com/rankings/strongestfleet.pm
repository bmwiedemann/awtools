
# add CV column:
s{<td>Owner</td>}{<td>CV</td>$&};
s{<tr bgcolor="#262626" align=center><td>\d+</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td>}{"$&<td>".(($1+$2*8+$3*20)*3)."</td>"}ge;

2;