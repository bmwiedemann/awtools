#!/usr/bin/perl -w
use strict;
use DBAccess;

foreach(qw(usersession fleets relations planetinfos)) {
	$dbh->do("REPAIR TABLE $_");
}
