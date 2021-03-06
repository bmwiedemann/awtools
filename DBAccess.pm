package DBAccess;
use strict;
use DBI;
use DBConf;
require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw($dbh &get_one_row &get_one_rowref &get_dbh &selectall_arrayref);

our $dbh;
$dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
#if(!$dbh) { $DBConf::connectionInfo=~s/192.168.236.1/192.168.235.1/; $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd); }
if(!$dbh) {die "DB err: $! "}

sub get_one_row($;@) {
   my($sql,$vars)=@_;
   $vars||=[];
   my $sth=$dbh->prepare_cached($sql);
#   if(!$sth) { return }
   my $r=$sth->execute(@$vars);
   if(!defined($r)) {return}
   my @row  = $sth->fetchrow_array;
   $sth->finish;
   return @row;
}

sub get_one_rowref($;@) {
   my($sql,$vars)=@_;
   $vars||=[];
   my $sth=$dbh->prepare_cached($sql);
   my $r=$sth->execute(@$vars);
   if(!defined($r)) {return}
   my $row  = $sth->fetchrow_arrayref;
   $sth->finish;
   return $row;
}

sub selectall_arrayref($;@)
{
	my($sql,$vars)=@_;
	$vars||=[];
	my $sth=$dbh->prepare_cached($sql);
	return $dbh->selectall_arrayref($sth,{}, @$vars);
}

sub get_dbh()
{ return $dbh }


1;
