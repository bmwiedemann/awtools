#!/usr/bin/perl
# special handler (can not work on specific URLs)

use strict;
package mangle::special::secure; # preprocess security check for convenience

#if($::options{name} eq "greenbird" && m/onLoad="document.login.secure.focus();">/) {
sub mangle($)
{ local $_=$_[0];
#return $_;
   eval {use strict;
	use Image::Magick;
#      $_.="test OK";
	# fetch security-check image to read text
   my $req=$::options{request};
   my $imgreq=HTTP::Request->new(GET => 'http://www1.astrowars.com/0/secure.php', $req->clone());
	$imgreq->header(Referer=>$req->uri);
   my $ua=$::options{ua};
   my $response = $ua->request($imgreq);
   my $content = $response->content;

	my $img=Image::Magick->new();
	$img->Set(magick=>"PNG");
	$img->BlobToImage($content);

	# read image
#	chdir "/home/aw/base/awread";
	require "$awstandard::basedir/base/awread/awread.pm";
	my $string=awread::process_awimg($img);
#	$_.="found $string";
   if($string=~m/^[0-9a-f]{5}$/) {
      s!<img src="/0/secure.php"[^>]*>!Security Measure!i; # drop original image link
   }
   s!<input type="text" id="secure" name="secure" maxlength="5"!$& value="$string"!;
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
