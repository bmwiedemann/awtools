my $r=$::options{req};
$r->content_type("image/x-icon");
$r->headers_out->add(expires=>awstandard::HTTPdate(time()+3600*24*30));
open(F, "<", "$awstandard::htmldir/awfavicon.ico");
local $/;
$_=(scalar <F>);
close(F);
print $_;

1;
