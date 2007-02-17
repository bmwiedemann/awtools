# real caching proxy code

package awcache;
use strict;
use warnings;
use Time::Local;
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
css text/css
htm.? text/html
txt text/plain
);

my $cachedir="/home/aw/html/awcache";


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
	my $content;
	my $mtime;
   my $res=open(FCACHE, "<", $path);
   if(!$res) {
		# re-fetch now
		print STDERR "re-fetching $path\n";
		my $request=$::options{request};
		my $UA=$::options{ua};
		my $response = $UA->request($request);
		$content = $response->content;
		(my $dir=$path)=~s![^/]*$!!;
		system("/bin/mkdir", "-p", $dir);
		open(my $fd, ">", $path);
		syswrite($fd, $content);
		close $fd;
			
		$response->scan(sub {
			if(lc($_[0]) eq "last-modified") {
				$mtime=HTTPtoEpoch($_[1]);
			}
		});

		utime(time(),$mtime,$path);
	} else {
      local $/;
      $content=<FCACHE>;
      close FCACHE;
		$mtime=(stat($path))[9];
   }
	my $t;
	foreach my $k (keys(%mimemap)) {
		if($path=~m/\.$k$/) {
			$t=$mimemap{$k};
		}
   }
   return ($content,$mtime,$t);
}

sub awservecache()
{
	my $u=$::options{url};
	$u=~s!http://!$cachedir/!;
#	print STDERR $u." url \n";
	my ($c,$mtime,$mimetype)=awgetcache($u);
	if($c) {
		my $r=$::options{req}; # apache request obj
		$r->status(200);
		$r->content_type($mimetype);
		$r->set_content_length(length($c));
		$r->set_last_modified($mtime);
		$r->header_out('Expires', HTTP::Date::time2str(time + 90*24*60*60)); # 90d
		$r->set_keepalive();
		$r->print($c);
		return 1;
	}
	return 2;
}

1;
