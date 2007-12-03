#!/usr/bin/perl -w
use strict;
use DBAccess;

if(0) {
my $trades=$dbh->selectall_arrayref("SELECT pid1,pid2 FROM `trades`");
my $sth=$dbh->prepare(qq!INSERT IGNORE INTO `alltrades` VALUES ('',?, ?)!);
foreach my $row (@$trades) {
   my $r=$sth->execute($row->[0], $row->[1]);
   my $r2=$sth->execute($row->[1], $row->[0]);
#   print "@$row $r $r2\n";
}
print scalar @$trades,"\n";
}

$dbh->do("UPDATE player SET otr=
      (SELECT COUNT(*) FROM planets, alltrades 
        WHERE ownerid=pid2 AND pid1=pid AND opop>=10 
      )");
