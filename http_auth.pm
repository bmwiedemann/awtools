#
# manage mysql DB passwords with brownie for AW
#
package http_auth;
use strict;
use warnings;
use DBAccess;
use Crypt::PasswdMD5;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&setdbpasswd &getdbpasswd &checkdbpasswd);

sub getdbpasswd($)
{
	return get_one_row("SELECT * FROM `http_auth` WHERE `username`=? LIMIT 1", [$_[0]]);
}

sub checkdbpasswd($$)
{
	my($user, $plain)=@_;
	if(!$user) { return 0}
	my($user2,$crypted,$group)=getdbpasswd($user);
	if(apache_md5_crypt($plain, $crypted) eq $crypted || crypt($plain, $crypted) eq $crypted) {
		return 1;
	}
	return 0;
}

sub setdbpasswd($;$)
{
	my($plain, $group)=@_;
	$group||=1;
	my $alli=$ENV{REMOTE_USER};
	my $crypted=apache_md5_crypt($plain);
	my $sth=$dbh->prepare("INSERT INTO `http_auth` VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE passwd=?");
	$sth->execute($alli, $crypted, $group, time(), $crypted);
}

1;
