package WP::DBI;
use DBConf;
use base 'Class::DBI';
use Class::DBI::utf8;
WP::DBI->connection($DBConf::connectionInfowp, $DBConf::dbuser, $DBConf::dbpasswd);


package WP::Words;
use base 'WP::DBI';
__PACKAGE__->table('words');
__PACKAGE__->columns(All => qw/name status/);
__PACKAGE__->utf8_columns(qq/name/);

