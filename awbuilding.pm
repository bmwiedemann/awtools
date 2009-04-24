#
# manage building DB feeding for AW
#
package awbuilding;
use strict;
use warnings;
use DBAccess2;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&getbuilding &update_building &update_building_pp);

sub getbuilding($@)
{
	my($cond,$vars)=@_;
	my $dbh=get_dbh;
	my $sth=$dbh->prepare_cached("SELECT * FROM `internalplanet` $cond");
	return $dbh->selectall_arrayref($sth, {}, @$vars);
}

sub update_building($$$%)
{
   my($sid, $pid,$isfloat,$p)=@_;
   return if not $sid || not $pid;
	my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $alli=$ENV{REMOTE_USER};
	if(!$alli || $alli eq "guest") {return}
   my $dbh=get_dbh;
	my $sth=$dbh->prepare_cached("SELECT * FROM `internalplanet` WHERE sidpid=?");
	my @oldv=$dbh->selectrow_array($sth, {}, $sidpid);
	my @v=($p->{pop}, $p->{pp}, $p->{hf}, $p->{rf}, $p->{gc}, $p->{rl}, $p->{sb});
	#print "feed old:@oldv new:@v<br/>";
	my $offs=4;
	my @newv=@oldv;
	if($isfloat || !defined($oldv[0])) {
		@newv=@v;
	} else {
		for my $i (0..6) {
			my $v=$v[$i]; 
			my $o=$oldv[$i+$offs];
			if(defined($v) && ($o<$v || $v<int($o))) {
				# force changes even with rounded input
				$newv[$i]=$v;
			}
		}
	}
	# TODO optimize: could return here if @newv==@oldv

	unshift(@v, $p->{ownerid});
	unshift(@v, $alli);
	my $u=$p->{updatetime};
	if(!defined($u)) {
		($u)=get_one_row("SELECT `lastupdate_at` FROM `brownieplayer` WHERE `pid`=?", [$p->{ownerid}]);
	}

	unshift(@v, $u||time());

	if(!defined($oldv[0])) {
		my $sth2=$dbh->prepare_cached("INSERT INTO `internalplanet` VALUES (?,?,?,?,?,?,?,?,?,?,?)");
   	$sth2->execute($sidpid, @v) or 
		print "err: ",$sth2->errstr,"<br/>";
	} else {
		my $sth2=$dbh->prepare_cached("UPDATE `internalplanet` SET time=?, alli=?, ownerid=?, pop=?, pp=?, b1=?, b2=?, b3=?, b4=?, b5=? WHERE sidpid=?");
   	$sth2->execute(@v, $sidpid) or 
		print "err: ",$sth2->errstr,"<br/>";
	}
}

sub update_building_pp($%)
{
	my($sidpid,$h)=@_;
   my $dbh=get_dbh;
	my $sth2=$dbh->prepare_cached("UPDATE `internalplanet` SET time=?, pp=? WHERE sidpid=?");
	$sth2->execute($h->{"time"}, $h->{pp}, $sidpid);
}

1;
