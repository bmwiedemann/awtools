# add Rasta link
s{Alliance Highscore</b>}{$& <a href="http://www.astrowars-tools.com/rankings.php?ranking=alliances" class="awtools">Rasta</a>};

# link AW alli page
s{(align=center><td>\d+</td><td>)([a-zA-Z]+)}{$1<a href="/0/Alliance/Info.php?tag=$2">$2</a>}g;

2;
