package awparser;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = "1.0";
@ISA = qw(Exporter);
our $d=$::data;
@EXPORT = 
qw($d
&tobool &toint &tofloat &unprettyprint
&parselastupdate &getcaption &parsetable
);

sub tobool($)
{
	$_[0]?1:0;
}

sub toint($)
{
   my $x=shift;
   if($x eq "0") {return 0}
   if($x=~m/^[+-]?[1-9]\d*$/) {return int($x)}
   return $x;
}

sub tofloat($)
{
   my $x=shift;
   if($x eq "0") {return 0}
   if($x=~m/^[+-]?[1-9.][0-9.]*$/) {return (0+$x)}
   return $x;
}

# strip thousand-markers and convert comma
sub unprettyprint($)
{
   my $value=shift;
   $value=~s/\.//g;
   $value=~tr/,/./;
   return $value+0;
}


sub parselastupdate($)
{
	my($textref)=@_;
	if($$textref =~m/Last Update (\d\d:\d\d:\d\d) GMT (\w{3} \d+)/) {
		$d->{lastupdate}="$1 $2";
		# re-use existing year/month inference algorithms
		$d->{lastupdatetime}=awstandard::parseawdate("$1 - $2");
	}
}

sub getcaption($)
{
	return (($_[0]=~m{<caption>(.*)</caption>})[0]);
}

# input: inputstr, callback($line, $startofline, $arrayrefcells)
sub parsetable($&)
{
	my $in=shift;
	my $func=shift;
	foreach my $line (m{<tr(.+?)</t[dh]>\s*</tr>}gs) {
		my @a=split(/<\/t[dh]>\s*<t[dh][^>]*>/, $line);
		$a[0]=~s/(.*)>\s*<t[dh]>(.*)/$2/;
		&$func($line, $1, \@a);
	}
}

1;
