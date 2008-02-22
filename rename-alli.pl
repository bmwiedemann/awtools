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

#$oldtag=~s/[^a-z]//g;
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

$dbh->do("DELETE FROM `toolsaccess` WHERE tag='$oldtag' OR othertag='$oldtag'");
settoolsaccess($newtag, $newtag, 255, 255);

#rename...
rename("$awstandard::allidir/$oldtag", "$awstandard::allidir/$newtag");
print "mv $awstandard::allidir/$oldtag $awstandard::allidir/$newtag\n";

system("vim '+\%s/^${oldtag}:/${newtag}:/' $basedir/.htpasswd");
# possibly manual intervention needed for awaccess

