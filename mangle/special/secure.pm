#!/usr/bin/perl
# special handler (can not work on specific URLs)

use strict;
package mangle::special::secure; # preprocess security check for convenience

#if($::options{name} eq "greenbird" && m/onLoad="document.login.secure.focus();">/) {
sub read($)
{ local $_=$_[0];
   eval {use strict;

#      $_.="test OK";
	# fetch security-check image to read text
   my $req=$::options{request};
   my $imgreq=HTTP::Request->new(GET => 'http://www1.astrowars.com/0/secure.php', $req->clone());
	$imgreq->header(Referer=>$req->uri);
   my $ua=$::options{ua};
   my $response = $ua->request($imgreq);
   my $content = $response->content;

	# write image to temp file
   use File::Temp qw(tempfile tempdir);
   my $dir = tempdir( CLEANUP => 1 );
   my ($fh, $filename) = tempfile( DIR => $dir );
	print $fh $content;
	close($fh);

	# read image
#	chdir "/home/aw/base/awread";
	require "/home/aw/base/awread/awread.pm";
	my $string=awread::read_awimg($filename);
#	$_.="found $string";
   s!<input type="text" name="secure" size="16" class=text!$& value=$string!;
   s!<img src="/0/secure.php"[^>]*>!Security Measure!i; # drop original image link
   if(0) { # submit the form so that non-premium users login works like premium
      sleep 2+rand(4);
      my $bodycontent="secure=$string&submit2=submit";
      m/<form action="([^"]*)"/;
      my $uri="http://www1.astrowars.com$1";
      my $newreq=HTTP::Request->new(POST => $uri, $req->clone(), $bodycontent);
      $newreq->header(Referer=>$req->uri);
      $newreq->header("Content-Type"=>"application/x-www-form-urlencoded");
      $newreq->header("Content-Length"=>length($bodycontent));
      $_.="URI $uri content $bodycontent ";
      $response = $ua->request($newreq);
      $_=$response->content;
   }
   } or $_.= $@;
   return $_;
}

1;
