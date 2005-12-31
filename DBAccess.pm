package DBAccess;
use DBI;
use Tie::DBI;
use DBConf;
use vars qw(@ISA @EXPORT);

@ISA = ();
@EXPORT = qw($dbh);

our $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}

1;
