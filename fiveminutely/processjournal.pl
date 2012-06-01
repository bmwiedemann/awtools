#!/usr/bin/perl -w
# synchronous processing of DB updates to avoid DB locks
use strict;
use awstandard;
use awinput;
use MLDBM qw(DB_File Storable);
use Fcntl qw(:flock O_RDWR);
my $jn="/var/tmp/aw-player.journal";
rename $jn, "$jn.processing";
open(my $journal, "<", "$jn.processing") or exit 0; # nothing to do
my @jentries=<$journal>;
close $journal;
exit 0 if not @jentries;
my %player;
tie %player, "MLDBM", "$dbdir/player.mldbm", O_RDWR, 0666;
foreach my $je (@jentries) {
	chomp($je);
	my ($k,$v)=split("=", $je);
	my @k=split(" ",$k);
	my @v=split(" ",$v);
	my $pid=shift @k;
	my %data=%{$player{$pid}};
	my $n=0;
	foreach $k (@k) {
		$v=$v[$n++];
		$v=~s/\.\d+$//;
		$data{$k}=$v;
	}
	$player{$pid}=\%data;
}
untie %player;

