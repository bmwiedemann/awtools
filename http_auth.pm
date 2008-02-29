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
qw(&setdbpasswd &getdbpasswd &checkdbpasswd
	&setdbpasswd_user &getdbpasswd_user &checkdbpasswd_user 
);

# expiry needs to be bigger than expiry2
our $expiry2=3600;
our $expiry=3600*24*50;

sub getdbpasswd($)
{
	return get_one_row("SELECT * FROM `http_auth` WHERE `username`=? LIMIT 1", [$_[0]]);
}

sub checkdbpasswd($$)
{
	my($user, $plain)=@_;
	if(!$user || !$plain) { return 0 }
	my($user2,$crypted,$group)=getdbpasswd($user);
	if(!$crypted) { return 0 }
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
	my $sth=$dbh->prepare("INSERT INTO `http_auth` VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE passwd=?, modified_at=?");
	$sth->execute($alli, $crypted, $group, time(), "x", $crypted, time());
}

# same as above for user passwords

sub getdbpasswd_user($)
{
	return get_one_row("SELECT * FROM `http_auth_user` WHERE `username`=? LIMIT 1", [$_[0]]);
}
# returns timestamp of last modification upon success
sub checkdbpasswd_user($$)
{
	my($user, $plain)=@_;
	if(!$user || !$plain) { return 0 }
	my($user2,$crypted,$stamp)=getdbpasswd_user($user);
	if(!$crypted) { return 0 }
	if(apache_md5_crypt($plain, $crypted) eq $crypted && $stamp+$expiry>time()) {
		return $stamp;
	}
	return 0;
}

sub setdbpasswd_user($$)
{
	my($user,$plain)=@_;
	my $stamp=checkdbpasswd_user($user,$plain);
	my $t=time();
	return if $stamp+$expiry2>$t;
	my $crypted=apache_md5_crypt($plain);
	my $sth=$dbh->prepare("INSERT INTO `http_auth_user` VALUES (?,?,?) ON DUPLICATE KEY UPDATE passwd=?, modified_at=?");
	$sth->execute($user, $crypted, $t,   $crypted, $t);
}

1;
