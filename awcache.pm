# real caching proxy code

package awcache;
use strict;
use warnings;
use Time::Local;
use HTTP::Date;
use awstandard;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT =
qw(&awservecache);

my %month;
foreach my $m (0..11) {
	$month{$awstandard::month[$m]}=$m;
}
my %mimemap=qw(
gif image/gif
png image/png
jpg image/jpg
css text/css
htm text/html
html text/html
txt text/plain
);

my $cachedir="$awstandard::htmldir/awcache";


# input: HTTP time format string
# output: integer seconds since epoch (1970-01-01)
sub HTTPtoEpoch($) {
	my($mday,$mon,$year,$hour,$min,$sec)=($_[0]=~m/^\w{3}, (\d+) (\w{3}) (\d+) (\d\d):(\d\d):(\d\d)/);
	return timegm($sec,$min,$hour,$mday,$month{$mon},$year);
}

# input: string of pathname to use as cache
# output: content of file
sub awgetcache($)
{ my($path)=@_;
#   my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($path);
	my $t;
	if($path!~m/\.(.{1,4})$/ || !($t=$mimemap{$1})) { 
		#print STDERR "no mime type for $path\n";
		return 2;
	}
	my $content;
	my $mtime;
   my $res=open(FCACHE, "<", $path);
   if(!$res) {
		# re-fetch now
#		print STDERR "re-fetching $path\n";
		my $request=$::options{request};
		my $UA=$::options{ua};
		# TODO drop if-modified-since to avoid 304 Not Modified response here ?
		my $response = $UA->request($request);
      if($response->code != 200) {$::options{response}=$response; return 2}
		$response->scan(sub {
			if(lc($_[0]) eq "last-modified") {
				$mtime=HTTPtoEpoch($_[1]);
			}
		});
      if(!$mtime) {return 2}
		$content = $response->content;
      if(!$content) {return 2}
		(my $dir=$path)=~s![^/]*$!!;
		system("/bin/mkdir", "-p", $dir);
		open(my $fd, ">", $path) or die $!;
		syswrite($fd, $content);
		close $fd;
			
		utime(time(),$mtime,$path);
	} else {
      local $/;
      $content=<FCACHE>;
      close FCACHE;
		$mtime=(stat($path))[9];
   }
   return ($content,$mtime,$t);
}

sub awservecache()
{
	my $u=$::options{url};
   return 2 if not $u=~m!http://([^/]+)(/.*)!;
   my($domain,$path)=(lc($1),$2); # domain is case-insensitive
   $u="$cachedir/$domain$path";
#	print STDERR $u." url \n";
	my ($c,$mtime,$mimetype)=awgetcache($u);
	if($c && $mtime && $mimetype) {
#      print STDERR "$mtime $mimetype \n";
		my $r=$::options{req}; # apache request obj
#		$r->status(200);
		$r->content_type($mimetype);
		$r->set_content_length(length($c));
      $r->update_mtime($mtime);
		$r->set_last_modified($mtime);
		$r->set_keepalive();
      if((my $rc = $r->meets_conditions) != 0) {
         $r->status($rc);
      } else {
         $r->headers_out->add('Expires', HTTP::Date::time2str(time + 90*24*60*60)); # 90d
   		$r->print($c);
      }
		return 1;
	}
	return 2;
}

1;
