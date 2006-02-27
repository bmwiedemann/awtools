s/(<input type="text" name="q\d+" size=")5(" class=text value=")(\d+)(">)/${1}2${2}1$4 \/ $3 /g;

s/(What)( you want to)/$1 do$2/;

s%(<b>Agreement</b></a></td>)(\n<td>|</td><td><a href="?/0/Trade/Buy)%$1
<td>|</td><td><a href="/0/Trade/Artifacts.php"><b>Artifacts</b></a></td>
<td>|</td><td><a href="/0/Trade/Sell.php"><b>Sell</b></a></td>$2%;

1;
