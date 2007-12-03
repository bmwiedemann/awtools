#!/usr/bin/perl -w
use strict;
use DBAccess;

sub dbtest($) {my($query)=@_;
   my $res=$dbh->selectall_arrayref($query);
   return if not $$res[0];
   print "query: $query\n";
   foreach my $row (@$res) {
      print join(", ", @$row)."\n";
   }
}

dbtest(
"SELECT fid,sidpid
FROM  `fleets` 
WHERE eta = 0 AND iscurrent = 1
GROUP BY sidpid
HAVING count(owner) > 1");

dbtest(
"SELECT fid,sidpid
FROM  `fleets` 
WHERE eta > 0 AND iscurrent = 1
GROUP BY sidpid,eta
HAVING count(eta) > 1
ORDER BY fid ASC");

dbtest(
"SELECT  * 
FROM  `fleets` 
WHERE 1  AND  `eta`  > 0 AND  `cv`  = 0 AND `cls` = 0 AND `trn` = 0;");

