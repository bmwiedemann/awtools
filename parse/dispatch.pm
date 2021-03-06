package parse::dispatch;
use strict;
use awstandard;
use awparser;
use Time::HiRes qw(gettimeofday tv_interval);

sub dispatch($)
{
	my($options)=@_;
	if($options->{data}){return $options->{data}}
	my $t0 = [gettimeofday];
	$d={"servertime"=>time(),
	     nclick=>$::options{nclick},
	   };
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
	$d->{parsetime}=tv_interval($t0);
	$options->{data}=$d; # cache for later re-use
	return $d;
}

1;
