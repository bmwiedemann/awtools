use strict;
use awparser;

if(m{Points: (\d+)</td>\n<td>\|</td><td>Rank: #(\d+)</td>}) {
   $d->{points}=int($1);
   $d->{rank}=int($2);
}

if($::options{url}=~m{Planets/$}) {
$d->{"spend_all_points"}=tobool(m{<td><a href="/0/Planets/Spend_All_Points.php"><b>Spend All Points</b></a></td>});

my @p;
parsetable($_, sub {
	my($line,$start, $a)=@_;
	if($line=~m/^ class="last/) {
		my @a=@$a;
		foreach my $a (@a) {$a=~s/.* ([+-]\d+)%/$1/;$a+=0}
		$d->{growthbonus}=shift(@a);
		$d->{totalpop}=shift(@a);
		$d->{productionbonus}=shift(@a);
		$d->{totalpp}=shift(@a);
		my $prodbonus=$d->{productionbonus}||0;
		$prodbonus=1+($prodbonus/100);
		$d->{hourlypp}=int(shift(@a)/$prodbonus+0.5);
	} elsif($a->[0]=~m/Detail\.php\?i=(\d+)/) {
		my %a=(id=>$1);
		#my %a=(siege=>((shift(@a) eq "602020")?1:0)); TODO
		my @label=qw(name population p2 growth pp production);
		for my $n(0..5) {$a{$label[$n]}=$a->[$n]}
		$a{name}=~s/.*>([^<>]+)<\/a>/$1/;
		my $name=$a{name};
		$name=~s/\s(\d+)$//;
		$a{pid}=$1;
		$a{sid}=awinput::systemname2id($name);
		$a{p2}=m{>(\d+)%</div>} and $a{population}+=$1/100;
      delete($a{p2});
		push(@p, \%a);
	} else {
		$d->{debug}=$line;
		$d->{debuga}=join(";",@$a);
	}
});

$d->{planet}=\@p;

}

2;
