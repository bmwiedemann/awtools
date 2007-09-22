package DBAccess;
use strict;
use DBI;
use DBConf;
require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw($dbh &get_one_row &get_one_rowref &get_dbh);

our $dbh = DBI->connect($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
if(!$dbh) {die "DB err: $!"}

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

sub get_dbh()
{ return $dbh }


1;
