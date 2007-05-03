package DBAccess2;
require Exporter;
use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(&get_dbh &get_one_row &get_one_rowref &get_table_fields);

# return DB handle
# useful when you only need the mysql DB for some stuff
sub get_dbh() {
   require DBAccess;
   return $DBAccess::dbh;
}

sub get_one_row($;@)
{
   require DBAccess;
   &DBAccess::get_one_row; # passes @_ into it
}

sub get_one_rowref($;@)
{
   require DBAccess;
   &DBAccess::get_one_rowref; # passes @_ into it
}

sub get_table_fields($)
{
   my($table)=@_;
   my $dbh=get_dbh;
   $dbh->selectcol_arrayref("EXPLAIN `$table`");
}

1;
