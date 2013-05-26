use strict;
use awparser;

my $n=0;
my @ta=();
parsetable($_, sub {
		my($line, $start, $a)=@_;
		#$d->{"x".$n++}=$a;
		return if($line=~m/th scope="col"/);
		if($a->[0]=~m{Preview</td>\s*<td colspan="2">([-+0-9]+)%}) {
			$d->{preview}=int($1);
			return;
		}
		$a->[0]=~m/id=(\d+")>([^<]+)/;
		push(@ta, {pid=>int($1), name=>$2, bonus=>int($a->[1]), status=>$a->[2]});
	});
$d->{ta}=\@ta;
# TODO new TAs allowed?

2;
