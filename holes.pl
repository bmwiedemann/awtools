#!/usr/bin/perl -w

use strict;
use CGI ":standard";
require "input.pm";

sub holesort { $$a[3]<=>$$b[3] || $$b[1]<=>$$a[2]}

my @holes;
{my $x=$::planets}
my $head=AWheader2("holes list");
#$head=~s!index!/cgi-bin/index!;
$head=~s!<a href="!$&/cgi-bin/!g;
print $head.
"sys: members:friends:others<br>\n";
for my $sid (1..4600) {
	my $friend=0;
	my $other=0;
	my $member=0;
	my $worstrel=10;
	foreach my $planet (@{$::planets{$sid}}) {
		my $p=$$planet{ownerid};
		my @rel=getrelation(playerid2name($p));
		if(!$p || $p<=2 || !$rel[0]) {$rel[0]=4}
		if($rel[0]<$worstrel) {$worstrel=$rel[0]}
		if($rel[0]>=5) {
			$friend++;
			if($rel[0]==9) {$member++}
		} else {$other++}
	}
	next if $member<3 || $member==12;
	push(@holes, [$sid, $member, $friend, $other, $worstrel]);
}

foreach(sort holesort @holes) {
	my ($sid, $member, $friend, $other, $worstrel)=@$_;
	my $c=getrelationcolor($worstrel);
	print span({-style=>"color: $c"},"status ").qq!<a href="/cgi-bin/system-info?id=$sid">$sid: $member:$friend:$other</a>!.br."\n";
}
print "</body></html>\n";