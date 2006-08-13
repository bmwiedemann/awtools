package awaccess;
require Exporter;
use vars qw(@ISA @EXPORT);

our (%read_access,%write_access);
our %allowedalli=("af"=>1, tgd=>1, love=>1, is=>1, kk=>1, tgt=>1, nain=>1, crs=>1, rats=>1, soup=>1, punx=>1, "pop"=>1, tuga=>1, xr=>1, crs=>1, tofw=>1, sk=>1, ld=>1,
      ""=>0);
# crs: temporary until 2006-05-05

@ISA = qw(Exporter);
@EXPORT = qw(%read_access %write_access %allowedalli %remap_planning %remap_alli);


#$read_access{af}=["idle"];
#$read_access{idle}=["af"];
$read_access{rats}=[qw(nain)];
$read_access{nain}=[qw(rats)];
#$read_access{tgd}=[qw(af)];
#$write_access{af}="af"; # unused yet
#our %remap_planning=(frs=>"is");
#our %remap_planning=(idle=>"af");
our %remap_alli=(
      sky=>"rats",
#      es=>"esb", zob=>"esb", vip=>"esb", qi=>"esb",
#      bzzz=>"love"
);

1;
