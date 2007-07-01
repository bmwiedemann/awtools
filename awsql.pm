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
qw(&update_premium &get_alli_match2);

sub update_premium($$)
{
   my($pid,$prem)=@_;
   return if not $pid;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("UPDATE `playerextra` SET `premium` = ? WHERE `pid` = ?");
   $sth->execute($prem, $pid);
}

# output: array with SQL string and placeholder vars
sub get_alli_match2($$;$)
{ my($alli,$bits,$what)=@_;
   if(!$alli || $alli eq "guest") {return (0,[])}
   $what||="alli";
   return ("( $what = toolsaccess.tag AND
         othertag = ? AND
         rbits & ? != 0 )", [$alli,$bits]);
}

1;