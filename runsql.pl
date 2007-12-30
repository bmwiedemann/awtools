#!/usr/bin/perl
use warnings;
use strict;
use DBAccess;
use Time::HiRes qw(gettimeofday tv_interval);

$dbh->{RaiseError} = 1;
my $sth=$dbh->prepare(shift);
my $t0=[gettimeofday];
my $res=$sth->execute();
print tv_interval($t0)*1e6,"\n";
print $res,"\n";
if($DBI::err) {print $DBI::err,"\n";}

