package DBAccess;
use DBI;
use Tie::DBI;
use DBConf;
use vars qw(@ISA @EXPORT);
our $dbms = 'mysql';
our $dbhost = 'localhost';
our $dbname = 'astrowars';
our $dbuser = 'bmwuser';
our $dbpasswd = 'insecuremysqlbmw';
our $connectionInfo="dbi:$dbms:$dbname;$dbhost";

@ISA = ();
#@EXPORT = qw($connectionInfo $dbuser $dbpasswd);
@EXPORT = qw($dbh);

our $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}

1;
