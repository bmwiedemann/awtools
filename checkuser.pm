package checkuser;
use strict;
use IO::Socket;
use Digest::MD5 qw(md5_hex);

my $req="POST /secured/check.php HTTP/1.0
Host: forum.rebelstudentalliance.co.uk
User-Agent: greenbird AWTools
Content-Type: application/x-www-form-urlencoded
Authorization: Basic cnNhZG1pbjp0cmVlYnVn\n";

sub check_user($$) { my($user,$pw)=@_;
#   username=greenbird&password=e1382f8efc5fbc20fe56532cf94b4858
   my $sock=IO::Socket::INET->new("forum.rebelstudentalliance.co.uk:80");
   if(!$sock) {return 0}
   my $content="username=$user&password=".md5_hex($pw);
   my $myreq=$req."Content-Length: ".length($content)."\015\012\015\012$content";
   print $sock $myreq;
   $sock->flush();
   my @reply=<$sock>;
   close($sock);
   my $reply=$reply[$#reply];
#   print $reply;
   if($reply=~/^1 "([^"]*)"/) {
      return $1;
   }
   return 0;
}

1;
