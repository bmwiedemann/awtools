#
# manage building DB feeding for AW
#
package awbuilding;
use strict;
use warnings;
use DBAccess2;
use awsql;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&getbuilding &getbuilding_alli &getbuilding_sidpid &getbuilding_player &update_building &update_building_pp);

my $expiry=15*24*60*60;

sub getbuilding($@)
{
	my($cond,$vars)=@_;
	my $dbh=get_dbh;
	my $sth=$dbh->prepare_cached("SELECT * FROM `internalplanet` $cond");
	return $dbh->selectall_arrayref($sth, {}, @$vars);
}

sub getbuilding_alli($$)
{
	my($cond,$vars)=@_;
	my ($allimatch, $amvars)=get_alli_match2($ENV{REMOTE_USER},32);
	return getbuilding(",toolsaccess WHERE $allimatch AND $cond", [@$amvars, @$vars]);
}

sub getbuilding_sidpid($$)
{
	my($sid,$pid)=@_;
	return getbuilding_alli("sidpid=? AND updated_at>?", [sidpid22sidpid3m($sid,$pid), time()-$expiry]);
}

sub getbuilding_player($)
{
	my($pid)=@_;
	return getbuilding_alli("ownerid=? AND updated_at>?", [$pid, time()-$expiry]);
}

sub update_building($$$%)
{
   my($sid, $pid,$isfloat,$p)=@_;
   return if not $sid || not $pid || ! defined($p->{pop});
	my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $alli=$ENV{REMOTE_USER};
	if(!$alli || $alli eq "guest") {return}
   my $dbh=get_dbh;
	my $sth=$dbh->prepare_cached("SELECT * FROM `internalplanet` WHERE sidpid=?");
	my @oldv=$dbh->selectrow_array($sth, {}, $sidpid);
	my @v=($p->{pop}, $p->{pp}, $p->{hf}, $p->{rf}, $p->{gc}, $p->{rl}, $p->{sb}, time());
	#print "feed old:@oldv new:@v<br/>";
	my $offs=4;
	my @newv;
	if($isfloat || !defined($oldv[0])) {
		@newv=@v;
	} else {
		for my $i (0..7) {
			my $v=$v[$i]; 
			my $o=$oldv[$i+$offs];
			# only update pop from inexact values when integer part changed:
			if(defined($v) && int($v)!=int($o)) {
			#if(defined($v) && (abs($o-$v)>0.1 || $v<int($o))) {
				# force changes even with rounded input
				$newv[$i]=$v;
			} else {$newv[$i]=$o}
		}
	}
	for my $i (0..7) { $newv[$i]||=0; }
	@v=@newv;
	# TODO optimize: could return here if @newv==@oldv

	unshift(@v, $p->{ownerid});
	unshift(@v, $alli);
	my $u=$p->{updatetime};
	if(!defined($u)) {
		($u)=get_one_row("SELECT `lastupdate_at` FROM `brownieplayer` WHERE `pid`=?", [$p->{ownerid}]);
	}

	unshift(@v, $u||time());

	if(!defined($oldv[0])) {
		my $sth2=$dbh->prepare_cached("INSERT INTO `internalplanet` VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
   	$sth2->execute($sidpid, @v) or 
		print "err: ",$sth2->errstr,"<br/>";
	} else {
		# diff
		my $same=1;
		for my $i (0..$#v) {
			if($v[$i] != $oldv[$i]) {$same=0; last};
		}
		if(!$same) {
			my $sth2=$dbh->prepare_cached("UPDATE `internalplanet` SET time=?, alli=?, ownerid=?, pop=?, pp=?, b1=?, b2=?, b3=?, b4=?, b5=?, updated_at=? WHERE sidpid=?");
	   	$sth2->execute(@v, $sidpid) or 
			print "err: ",$sth2->errstr,"<br/>";
		} else {
#			print "still same values - not updating<br/>\n";
		}
	}
}

# allow to auto-update pop+PP
sub update_building_pp($%)
{
	my($sidpid,$h)=@_;
   my $dbh=get_dbh;
	my $sth2=$dbh->prepare_cached("UPDATE `internalplanet` SET time=?, pp=?, pop=? WHERE sidpid=?");
	$sth2->execute($h->{"time"}, $h->{pp}, $h->{"pop"}, $sidpid);
}

#sub update_building_pop ?

1;
