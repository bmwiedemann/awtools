package awparser;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
our $d=$::data;
@EXPORT = 
qw($d
&tobool
);

sub tobool
{
	$_[0]?1:0;
}

