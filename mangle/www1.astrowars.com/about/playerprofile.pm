if($::options{url}=~m%^http://www1\.astrowars\.com/about/playerprofile.php\?((?:id)|(?:name))=(.+)%) { 
   my $id=$2;
   my $arg=$1;
   s%^</td></tr></table>%$& $::bmwlink/relations?$arg=$id">AWtools($id)</a><br>%m;
}

1;
