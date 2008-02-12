if($::options{url}=~m%^http://www1\.astrowars\.com/rankings/alliances/(\w+)\.php%) { 
   my $tag=$1;
   s%^</td></tr></table>%$& $::bmwlink/alliance?alliance=$tag">AWtools($tag)</a> <a href="/0/Alliance/Info.php?tag=$tag">AW $tag</a><br>%m;
}

2;
