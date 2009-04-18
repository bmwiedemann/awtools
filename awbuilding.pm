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
qw(&update_building);

sub update_building($$$%)
{
   my($sid, $pid,$isfloat,$p)=@_;
   return if not $sid || not $pid;
	my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $alli=$ENV{REMOTE_USER};
	if(!$alli || $alli eq "guest") {return}
   my $dbh=get_dbh;
	my $sth=$dbh->prepare_cached("SELECT * FROM `internalplanet` WHERE alli=? AND sidpid=?");
	my @oldv=$dbh->selectrow_array($sth, {}, $alli,$sidpid);
	my @v=($p->{pop}, $p->{pp}, $p->{hf}, $p->{rf}, $p->{gc}, $p->{rl}, $p->{sb});
	print "feed old:@oldv new:@v<br/>";
	my @newv=@oldv;
	if($isfloat || !defined($oldv[0])) {
		@newv=@v;
	} else {
		for my $i (0..6) {
			my $v=$v[$i]; 
			if($oldv[$i]<$v || $v<int($oldv[$i])) {
				# force changes even with rounded input
				$newv[$i]=$v;
			}
		}
	}

	unshift(@v, $p->{ownerid});
	unshift(@v, $alli);
	if(!defined($oldv[0])) {
		my $sth2=$dbh->prepare_cached("INSERT INTO `internalplanet` VALUES (?,?,?,?,?,?,?,?,?,?)");
   	$sth2->execute($sidpid, @v) or 
		print "err: ",$sth2->errstr,"<br/>";
	} else {
		my $sth2=$dbh->prepare_cached("UPDATE `internalplanet` SET alli=?, ownerid=?, pop=?, pp=?, b1=?, b2=?, b3=?, b4=?, b5=? WHERE sidpid=?");
   	$sth2->execute(@v, $sidpid) or 
		print "err: ",$sth2->errstr,"<br/>";
	}
}

1;
