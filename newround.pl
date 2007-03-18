#!/usr/bin/perl -w
use strict;
use DBAccess;
my $oldname="gold7";
my $newname=$oldname;
$newname=~s/(\d+)$/1+$1/e;

mkdir "html/$newname";
unlink("html/round");
symlink($newname, "html/round");
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

system("find html/alli/*/l -name \*.png|xargs rm -f");
system("cat ../dbm/empty.dbm > ~/db/useralli.dbm");
system("cat ../dbm/empty.dbm > ~/db/points.dbm");
system("perl -i.bak -pe 's/(round=.?)$oldname/\$1$newname/' Makefile topwars");
system('for f in /home/aw/db2/*planets.dbm ; do cat ../dbm/empty.dbm > $f ; done');
system("find html/alli/*/l/ -name \*.png|xargs rm -f");

awstandard::set_file_content("alltrades.csv", "id1\tid2\n");
awstandard::set_file_content("systemexportsecret", rand(1000000000000000)."\n");

