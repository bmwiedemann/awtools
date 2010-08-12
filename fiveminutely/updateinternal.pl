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
	my $hourlyprod=int($pop)+int($rf); # TODO should use real pop here as pop-update happens after PP-update
	my $prods=playerid2production($ownerid);
	my $bonusses=pop(@$prods);
	my $ppbonus=$bonusses->[0]||1;
	my $popbonus=$bonusses->[3]||1;
	my $tdiff=$now-$time;
	my $hourpart=$tdiff/3600;
	$pp+=$hourlyprod*$ppbonus*$hourpart;
	my $poplevel=int($pop)+1;
	my $foodneeded=(9*$poplevel-9)*$poplevel+3;
	$pop+=(int($hf)+1)*$popbonus*$hourpart/$foodneeded;
	diag "prod: @$bonusses new PP: $pp new pop: $pop";
	diag "\n";
	update_building_pp($sidpid, {"time"=>$now, pp=>$pp, "pop"=>$pop});
	#exit 0;
}

