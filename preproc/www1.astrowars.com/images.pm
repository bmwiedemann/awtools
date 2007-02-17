use awcache;

my $u=$::options{url};
my $cachedir="/home/aw/html/awcache";
$u=~s!http://!$cachedir/!;

return 2;
my $c=awservecache($u);
if($c) {
   my $r=$::options{req}; # apache request obj
   my $t;
   if($u=~m/\.gif$/) {
      $t="image/gif";
   }
   $r->content_type($t);
   $r->set_keepalive();
   $r->print($c);
   return 1;
}

2;
