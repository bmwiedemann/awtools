package preproc::dispatch;
use strict;
use awstandard;
use awinput;
use DBAccess;
use Time::HiRes qw(gettimeofday tv_interval); # for profiling

#our $g;
#my %specialname=qw(
#      greenbird 1
#      pentabarf 1
#);
#my $origbmwlink="<a class=\"awtools\" href=\"http://$bmwserver/cgi-bin";

# input options hash reference
sub preproc_dispatch(%) { my($options)=@_;
   my $url=$$options{url};
#   $g=$specialname{$$options{name}};
#   my $t2=[gettimeofday];
   %::options=%$options;
#   $::bmwlink=$origbmwlink;
#   my %info=("alli"=>$ENV{REMOTE_USER}, "user"=>$$options{name}, "proxy"=>$$options{proxy}, "ip"=>$$options{ip});
#   my $gameuri=defined($url) && $url=~m%^http://www1\.astrowars\.com/%;
#   my $ingameuri=$gameuri && $url=~m%^http://www1\.astrowars\.com/0/%;
#   my $alli="\U$ENV{REMOTE_USER}";

   my $module="";
   foreach my $m (url2pm($url)) {
      my $include="preproc/$m.pm";
      next if(!-e $include);
      open(my $f, $include);
      local $/;
      my $perlinc=<$f>;
      close $f;
		$_=undef;
      my $ret=eval $perlinc;
      next if $ret==2;
      if($@) {$module="error in $m: $@";}
#      $module.=" preprocd $m"; 
      $brownie::process::browniedone=200;
#      print "\n$module\n";
		if(defined($_)) {
			my $r=$$options{req};
			$::options{mime} and $r->content_type($::options{mime});
			$r->print($_);
		}
      # is handled now, so stop filtering
      last;
   }
#   if($g) {
#      $info{page}=join(", ",@module). " $module";
#   } else { $info{page}=$module }
#   $brownie::process::browniedone=201;
}

1;
