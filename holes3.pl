#!/usr/bin/perl
use strict;
use warnings;
use CGI ":standard";
use DBAccess;
use awinput;
awinput_init(1);

sub holesort { $$a[3]<=>$$b[3] || $$b[1]<=>$$a[2]}

my $alli=$ENV{REMOTE_USER};
my $aid=alliancetag2id($alli);
#die "error: tag $alli not found" if(!$aid);
exit 0 if(!$aid);
my @members=allianceid2members($aid);
#die "error: $alli has zero members" if(!@members || !$members[0]);
exit 0 if(!@members || !$members[0]);

#print "@members";
my @cond=();
foreach my $m (@members) {
   push(@cond, "`ownerid` = $m");
}
my $qu="SELECT `sidpid` FROM `planets` WHERE ".join(" OR ",@cond);
my $qres=$dbh->selectall_arrayref($qu);
my %systems;
foreach my $a (@$qres) {
   $systems{int($$a[0]/13)}++;
#   print join(" ",@$a),"\n";
}
#print keys %systems;

my @holes;
for my $sid (keys %systems) {
	my $friend=0;
	my $other=0;
	my $member=0;
	my $worstrel=10;
	foreach my $planet (systemid2planets($sid)) {
      next if(!$planet);
		my $p=$$planet{ownerid};
		my @rel=getrelation(playerid2name($p));
		if(!$p || $p<=2 || !$rel[0]) {$rel[0]=4}
		if($rel[0]<$worstrel) {$worstrel=$rel[0]}
		if($rel[0]>=5) {
			$friend++;
			if($rel[0]==9) {$member++}
		} else {$other++}
	}
	next if $member<3 || ($other==0 && $friend==$member);
	push(@holes, [$sid, $member, $friend, $other, $worstrel]);
}

foreach(@holes) {
	print join("\t",@$_),"\n";
#	my ($sid, $member, $friend, $other, $worstrel)=@$_;
#	my $c=getrelationcolor($worstrel);
#	print span({-style=>"color: $c"},"status ").qq!<a href="/cgi-bin/system-info?id=$sid">$sid: $member:$friend:$other</a>!.br."\n";
}
