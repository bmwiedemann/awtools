package awaccess;
require Exporter;
use vars qw(@ISA @EXPORT);

our (%read_access,%write_access);
our %allowedalli=("af"=>1, "tgd"=>1, "xr"=>1, "love"=>1, "kk"=>1, "wink"=>1, "ocb"=>1, "fsb"=>1, ""=>0);

@ISA = qw(Exporter);
@EXPORT = qw(%read_access %write_access %allowedalli);


$read_access{af}=[qw"af"];
#$read_access{is}=[qw(is fun af)];
#$read_access{tgd}=[qw(af)];
$write_access{af}="af"; # unused yet

1;
