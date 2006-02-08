package DBAccess;
use DBI;
use DBConf;
require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw($dbh);

our $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}

1;
