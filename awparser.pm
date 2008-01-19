package awparser;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
our $d=$::data;
@EXPORT = 
qw($d
&tobool &toint &tofloat &unprettyprint
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

