#!/usr/bin/perl -w

use strict;
require "input.pm";

{my $x=$::planets}
print "<html><head><title>holes list</title></head><body>sys: members:friends:others<br>\n";
for my $sid (1..3000) {
	my $friend=0;
	my $other=0;
	my $member=0;
	foreach my $planet (@{$::planets{$sid}}) {
		my $p=$$planet{ownerid};
		my @rel=getrelation(playerid2name($p));
		if($rel[0] && $rel[0]>=5) {
			$friend++;
			if($rel[0]==9) {$member++}
		} else {$other++}
	}
	next if $member<5 || $friend==12;
	print qq!<a href="/cgi-bin/system-info?id=$sid">$sid: $member:$friend:$other</a><br>\n!;
}
print "</body></html>\n";
