use strict;
use Image::Magick;

my $r=$::options{req};
my $img=Image::Magick->new();
$img->Set(magick=>"PNG");
$img->BlobToImage($_);

my $string="";
eval {
require "$awstandard::basedir/base/awread/awread.pm";
$string=awread::process_awimg($img);
};

$r->content_type("text/plain");
$_=$string||"";
#if($string && $string=~m/^[0-9a-f]{5}$/) { }

30;
