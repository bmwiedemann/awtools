use DBAccess;
use Tie::DBI;

# feed and mangle code not reached without content-type
my $pid=$::options{pid};
if($::options{post} && $pid) {
	my $param=$::options{post};
	my $immediate=($param=~m/immediatebuild=on/);

	my $dbh=get_dbh();
	my %h;
	tie %h,'Tie::DBI',$dbh,'playerprefs','pid',{CLOBBER=>1};
	my %data=%{$h{$pid}||{}};
	$data{flags}=($immediate?1:0);
	$h{$pid}=\%data;
}

# continue normal processing
2;
