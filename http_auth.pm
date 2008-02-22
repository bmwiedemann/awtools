#
# manage mysql DB passwords with brownie for AW
#
package http_auth;
use strict;
use warnings;
use DBAccess;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&setdbpasswd &getdbpasswd);

sub getdbpasswd($)
{
	return get_one_row("SELECT * FROM `http_auth` WHERE `username`=? LIMIT 1", [$_[0]]);
}

sub setdbpasswd($;$)
{
	my($plain, $group)=@_;
	$group||=1;
	my $alli=$ENV{REMOTE_USER};
	my $crypted=crypt($plain,join '', ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64]);
	my $sth=$dbh->prepare("INSERT INTO `http_auth` VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE passwd=?");
	$sth->execute($alli, $crypted, $group, time(), $crypted);
}

1;
