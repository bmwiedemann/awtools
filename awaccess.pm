# this file defines permissions for allis
# e.g. sharing of info in tools
package awaccess;
use awstandard;
use DB_File;
use Fcntl qw(:flock O_RDONLY);
require Exporter;
use vars qw(@ISA @EXPORT);

our (%read_access,%write_access,%allowedalli);

tie(%allowedalli, "DB_File", "$awstandard::dbmdir/allowedalli.dbm", O_RDONLY, 0, $DB_HASH);

# crs: temporary until 2006-05-05

@ISA = qw(Exporter);
@EXPORT = qw(%read_access %write_access %allowedalli %remap_planning %remap_relations %remap_alli);


$read_access{af}=["rats"];
$read_access{rats}=["af"];
$read_access{fir}=["ice"];
$read_access{ice}=["fir"];
$read_access{lba}=["lbb"];
$read_access{lbb}=["lba"];
$read_access{sj}=["sjma"];
$read_access{sjma}=["sj"];
$read_access{xr}=["en"];
$read_access{en}=["xr"];
#$read_access{rats}=[qw()];
#$read_access{nain}=[qw()];
#$read_access{sky}=[qw()];
#$read_access{tgd}=[qw(af)];
#$write_access{af}="af"; # unused yet
#our %remap_planning=(frs=>"is");
our %remap_planning=(
      rats=>"af",
      en=>"xr",
      );
our %remap_relations=(
      rats=>"af",
      en=>"xr",
      );
our %remap_alli=(
      lbb=>"lba",
      ice=>"fir",
      sjma=>"sj",
#      es=>"esb", zob=>"esb", vip=>"esb", qi=>"esb",
);

1;
