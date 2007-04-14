package DBAccess2;
require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(&get_dbh);

# return DB handle
# useful when you only need the mysql DB for some stuff
sub get_dbh() {
   require DBAccess;
   return $DBAccess::dbh;
}

1;
