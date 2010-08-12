#!/usr/bin/perl -w
use strict;
use DBAccess;

$dbh->do("DELETE  FROM `relations` WHERE alli = 'guest' AND `info` LIKE '%http://%'");
