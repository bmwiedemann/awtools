package model::bestguarded;
use strict;
use DBAccess2;
use awclassdbi;
use awinput;

sub prune()
{
	my $prunetime=3600*24*3;
	my $sql="DELETE FROM `bestguarded` WHERE `time`<?";
	#print $sql;
	my $dbh=get_dbh;
	$dbh->do($sql, {}, time-$prunetime);
}

sub add($$$)
{
	my($sid,$pid,$cv)=@_;
	my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $obj = AW::BestGuarded->find_or_create({sidpid=>$sidpid});
	my $now=time(); 
	$now-=($now+3600)%86400; # adjust to GMT+1 (CET) ; round down to midnight update
	if($obj->time && ($obj->time == $now)) {return}
	#print ref($obj),$obj,"\n"; exit 0;
	$obj->cv($cv);
	$obj->time($now);
	$obj->update;
}

sub lookup($$)
{
	my($sid,$pid)=@_;
	my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $obj = AW::BestGuarded->retrieve($sidpid);
	return undef unless $obj;
	return ($obj->cv, $obj->time);
}

1;
