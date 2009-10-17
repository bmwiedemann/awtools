#!/usr/bin/perl -w
use strict;
use awinput;
use awbuilding;

awinput_init(1);

sub diag($)
#{print @_}
{}

my $toupdate=getbuilding("WHERE `time`<UNIX_TIMESTAMP()-16*60", []);
my $now=time;

foreach my $row (@$toupdate) {
	my @v=@$row;
	diag "update @v ";
	my($sidpid,$time,$alli,$ownerid,$pop,$pp,$hf,$rf)=@v;
	$ENV{REMOTE_USER}=$alli;
	my $hourlyprod=int($pop)+int($rf);
	my $prods=playerid2production($ownerid);
	my $bonusses=pop(@$prods);
	my $bonus=$bonusses->[0]||1;
	my $tdiff=$now-$time;
	$pp+=$hourlyprod*$bonus*$tdiff/3600;
	diag "prod: @$bonusses new PP: $pp";
	diag "\n";
	update_building_pp($sidpid, {"time"=>$now, pp=>$pp});
	#exit 0;
}

