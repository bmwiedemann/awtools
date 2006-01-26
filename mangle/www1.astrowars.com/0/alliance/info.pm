if($::options{url}=~m/\?tag=(\w+)/) {
   my $tag=$1;
   s%<b>Alliance / Info</b></td>%$& <td>$::bmwlink/alliance?alliance=$tag">AWtools($tag)</a></td><td>|</td>%;
}

1;
