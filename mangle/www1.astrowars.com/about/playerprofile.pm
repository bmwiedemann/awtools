use awsql;

if($::options{url}=~m%^http://www1\.astrowars\.com/about/playerprofile.php\?((?:id)|(?:name))=(.+)%) { 
   my $id=$2;
   my $arg=$1;
   s%^</td></tr></table>%$& $::bmwlink/relations?$arg=$id">AWtools($id)</a><br>%m;
   my $prem=m!<small>Premium Member</small>! || 0;
   my $pid=$id;
   if($arg eq "name") {$pid=playername2idm($id);}
   update_premium($pid, $prem);
}

1;
