#
# manage common SQL for AW
#
package awsql;
use strict;
use warnings;
use DBAccess2;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&update_premium);

sub update_premium($$)
{
   my($pid,$prem)=@_;
   return if not $pid;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("UPDATE `playerextra` SET `premium` = ? WHERE `pid` = ?");
   $sth->execute($prem, $pid);
}


1;
