if($::options{url}=~m%^http://www1\.astrowars\.com/rankings/alliances/(\w+)\.php%) { 
   my $tag=$1;
   s%^</td></tr></table>%$& $::bmwlink/alliance?alliance=$tag">AWtools($tag)</a><br>%m;
}

1;
