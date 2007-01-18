package awaccess;
require Exporter;
use vars qw(@ISA @EXPORT);

our (%read_access,%write_access);
our %allowedalli=("af"=>1, tgd=>1, love=>1, is=>1, kk=>1, tgt=>1, nain=>1, crs=>1, rats=>1, soup=>1, punx=>1, "pop"=>1, tuga=>1, xr=>1, crs=>1, tofw=>1, sk=>1, ld=>1, sky=>1, frs=>1, the=>1, lba=>1, en=>1, ocb=>1,
      ""=>0);
# crs: temporary until 2006-05-05

@ISA = qw(Exporter);
@EXPORT = qw(%read_access %write_access %allowedalli %remap_planning %remap_relations %remap_alli);


$read_access{af}=["is"];
$read_access{is}=["af"];
#$read_access{rats}=[qw()];
#$read_access{nain}=[qw()];
#$read_access{sky}=[qw()];
#$read_access{tgd}=[qw(af)];
#$write_access{af}="af"; # unused yet
#our %remap_planning=(frs=>"is");
our %remap_planning=(
      #nain=>"rats",
      is=>"af",
      );
our %remap_relations=(
      is=>"af",
      );
our %remap_alli=(
#      seux=>"niai",
      lbb=>"lba",
#      es=>"esb", zob=>"esb", vip=>"esb", qi=>"esb",
#      bzzz=>"love"
);

1;
