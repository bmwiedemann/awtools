use strict;
BEGIN {$ENV{HTTP_COOKIE}=$::options{headers}->{Cookie};} # allow parsing cookies from CGI module
use warnings;
use CGI;
my $r=$::options{req};
$r->content_type("text/html");

(my $urlparam)=($::options{url}=~/\?(.*)/);
my $param=$::options{post}||$urlparam;
my $q = new CGI($param);

foreach my $c (qw(PHPSESSID c_user)) {
   if((my $v=$q->param($c))) {
      print "setting $c = $v<br>";
      my $t=awstandard::HTTPdate(time()+3600*24*90);
      my $domain=(($c eq "PHPSESSID")?"host=www1.astrowars.com":"domain=.astrowars.com");
      $r->headers_out->add("Set-Cookie","$c=$v; expires=$t; path=/; $domain");
   }
}

print "<html><body><form>";
foreach my $c (qw(PHPSESSID c_user)) {
   my $value=$q->cookie($c);

   print qq!$c = <input name="$c" value="$value"><br>!;

}
print "<input type=submit></form>";

1;
