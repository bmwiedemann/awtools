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
qw(&update_premium &set_useralli &get_alli_match2);

sub update_premium($$)
{
   my($pid,$prem)=@_;
   return if not $pid;
   my $dbh=get_dbh;
   my $sth=$dbh->prepare_cached("UPDATE `playerextra` SET `premium` = ? WHERE `pid` = ?");
   $sth->execute($prem, $pid);
}

sub set_useralli($$)
{
   my($pid,$alli)=@_;
   my $dbh=get_dbh;
   if(!$alli) {
      my $sth=$dbh->prepare("DELETE FROM `useralli` WHERE `pid`=?");
      $sth->execute($pid);
      return;
   }
   my $sth=$dbh->prepare("REPLACE INTO `useralli` VALUES (?,?)");
   $sth->execute($pid,$alli);
}

# output: array with SQL string and placeholder vars
sub get_alli_match2($$;$)
{ my($alli,$bits,$what)=@_;
   if(!$alli || $alli eq "guest") {return (0,[])}
   $what||="alli";
   return ("( $what = toolsaccess.tag AND
         othertag = ? AND
         rbits & rmask & ? != 0 )", [$alli,$bits]);
}


# for cleanup
#SELECT *,count(alliances.tag) as c FROM `toolsaccess` LEFT JOIN alliances ON alliances.tag=toolsaccess.tag LEFT JOIN player ON alliance=aid WHERE toolsaccess.tag=othertag GROUP BY toolsaccess.tag ORDER BY c ASC

1;
