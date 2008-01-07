package parse::dispatch;
use strict;
use awstandard;
use awparser;

sub dispatch($)
{
	my($options)=@_;
	$d={"servertime"=>time()};
	my $url=$options->{url};
	my @module=url2pm($url);
	my $module="";
	foreach my $m (reverse @module) {
		my $include="$awstandard::codedir/parse/$m.pm";
#		$_.=$include;
		next if(!-e $include);
		# call per-page parsing modules that fill in data hash
		my $ret=do $include;
		next if $ret==2;
		if($@) {$module="error in $m: $@";}
		else { $module="parsed $m";} # for the log
		# is handled now, so stop filtering
		last;
	}
	return $d;
}

1;
