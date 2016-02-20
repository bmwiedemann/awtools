# this file must remain private to not reveal the database password
# use, copy, modify under terms of GNU GPL v2 or later
package DBConf;
use vars qw(@ISA @EXPORT);
our $dbms = 'mysql';
our $dbhost = 'awdb.zq1.de';
our $dbname = 'astrowars';
our $dbuser = 'astrowars';
our $dbpasswd = "xxx";
our $connectionInfo="dbi:$dbms:$dbname;$dbhost";
our $connectionInfowp="dbi:$dbms:wikipedia;$dbhost";

@ISA = ();
@EXPORT = qw($connectionInfo $dbuser $dbpasswd);

1;
