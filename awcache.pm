# real caching proxy code

package awcache;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT =
qw(&awservecache);

# input: string of pathname to use as cache
# output: content of file
sub awservecache($)
{ my($path)=@_;
#   my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($path);
   my $res=open(FCACHE, "<", $path);
   if($res) {
      local $/;
      $res=<FCACHE>;
      close FCACHE;
      return $res;
   }

   # re-fetch now
   my $req=$::options{request};
   my $UA=$::options{ua};
   my $response = $UA->request($req);
   my $content = $response->content;
   (my $dir=$path)=~s![^/]*$!!;
   system("/bin/mkdir", "-p", $dir);
   open(my $fd, ">", $path);
   syswrite($fd, $content);
   close $fd;
   return $content;
}

1;
