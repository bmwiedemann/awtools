#!/usr/bin/perl
# admin-only command-line tool to rename an alli in AWTools
use strict;
use warnings;
use Fcntl qw(O_RDWR);
use awstandard;
use awinput;
use DBAccess2;

my $oldtag=shift;
my $newtag=shift;

$oldtag=~s/[^a-z]//g;
$newtag=~s/[^a-z]//g;
if(!$oldtag || !$newtag) {
   print STDERR "usage: $0 oldtag newtag\n";
   exit 1;
}

my $dbh=get_dbh;
foreach my $n (qw(fleets intelreport planetinfos logins plhistory relations)) {
   my $sth=$dbh->prepare("UPDATE `$n` SET `alli` = ? WHERE `alli` = ?");
   $sth->execute($newtag, $oldtag);
}

$dbh->do("DELETE FROM `toolsaccess` WHERE tag='$oldtag' AND othertag='$oldtag'");
$dbh->do("INSERT INTO `toolsaccess` VALUES('$newtag','$newtag',255,255)");


foreach(qw(relation.dbm relation.dbm.lock planets.dbm planets.dbm.lock)) {
   rename("$awstandard::dbmdir/$oldtag-$_", "$awstandard::dbmdir/$newtag-$_");
   print "mv $awstandard::dbmdir/$oldtag-$_ $awstandard::dbmdir/$newtag-$_\n";
}

if(0) {
   my %aa;
   awinput::opendb(O_RDWR, "$awstandard::dbmdir/allowedalli.dbm", \%aa);
   $aa{$newtag}=$aa{$oldtag};
   delete $aa{$oldtag};
   untie %aa;
}

#rename...
rename("$awstandard::allidir/$oldtag", "$awstandard::allidir/$newtag");
print "mv $awstandard::allidir/$oldtag $awstandard::allidir/$newtag\n";

system("vim '+\%s/^${oldtag}:/${newtag}:/' $basedir/.htpasswd");
# possibly manual intervention needed for awaccess

