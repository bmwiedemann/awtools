#!/usr/bin/perl -w
use strict;
use DBAccess;
use awstandard;
my $oldname="gold7";
my $newname=$oldname;
$newname=~s/(\d+)$/1+$1/e;

mkdir "html/$newname";
unlink("html/round");
symlink($newname, "html/round");
foreach(qw"player alliances") {
   system("cp -a $_.csv $_.csv.$oldname");
}
system("sudo cp -a /var/lib/mysql/astrowars /var/lib/mysql/astrowars_$oldname");
$dbh->do("UPDATE planets SET ownerid=0");
$dbh->do("TRUNCATE TABLE `cdcv`");
$dbh->do("TRUNCATE TABLE `alltrades`");
$dbh->do("TRUNCATE TABLE `trades`");
$dbh->do("TRUNCATE TABLE `battles`");
$dbh->do("TRUNCATE TABLE `fleets`");
$dbh->do("TRUNCATE TABLE `plhistory`");
$dbh->do("TRUNCATE TABLE `planetinfos`");
$dbh->do("TRUNCATE TABLE `player`");

system("find $awstandard::allidir/*/l -name \*.png|xargs rm -f");
system("cat empty.dbm > $awstandard::dbmdir/useralli.dbm");
system("cat empty.dbm > $awstandard::dbmdir/points.dbm");
system("perl -i.bak -pe 's/(round=.?)$oldname/\$1$newname/' Makefile");
system("for f in $awstandard::dbmdir/*planets.dbm ; do cat empty.dbm > \$f ; done");
system("for f in $awstandard::dbmdir/*relation.dbm ; do ./clear.pl \$f ; done");

awstandard::set_file_content("alltrades.csv", "id1\tid2\n");
awstandard::set_file_content("player.csv", "rank\tpoints\tid\tscience\tculture\tlevel\thome_id\tlogins\tfrom\tjoined\talliance\tname\ttrade\n");
awstandard::set_file_content("systemexportsecret", rand(1000000000000000)."\n");

system("./importcsv.pl ; cp -a newdb/player.mldbm db/ ; chmod 664 db/*");

