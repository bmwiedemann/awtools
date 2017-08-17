#!/usr/bin/perl

package awread;
use strict;
#use warnings;
use Image::Magick;

my $fontsize=9;
our $totalchars=5;
our %digits;
our %letterbytes;
our @letters=(0..9, "a".."f");

sub narrow_text($)
{
	my ($img)=@_;
	my ($w,$h)=$img->Get('columns','rows');
	my ($mincol,$maxcol);
	{

		# column statistics to find left+right edges

		my @colstats=();
		foreach my $x (0..($w-1)) {
			my @p=$img->GetPixels(
				height=>$h,
				width=>1,
				x=>$x,
				y=>0,
				normalize=>"true",
				map=>"RGB",
			);
			my $sum=0;
			foreach(@p) {
				$sum+=$_;
			}
			$sum/=3;
			$colstats[$x]=$sum;
			if(!defined($mincol) && $sum>1) { $mincol=$x-3; }
		}
		if($mincol<0){$mincol=0}
		for(my $x=$#colstats; $x>=0; --$x) { # search from right
			if(!defined($maxcol) && $colstats[$x]>1) { $maxcol=$x+2; }
		}

#		foreach my $i (1..($totalchars-1)) {
#			if($colstats[$mincol+$i*$fontsize]>1) {$mincol--;last;} # standardize alignment with leading "1"s, assuming fuzz-line is just 1 px wide
#		}
	}
	my $coldiff=$maxcol-$mincol;


	my ($minrow,$maxrow);
	{
		# row statistics to narrow top+bottom edges
		my $img=$img->Clone();
		#print "$mincol $maxcol $coldiff\n";
		$img->Crop(x=>$mincol, y=>0, height=>$h, width=>$coldiff);
		my ($w,$h)=$img->Get('columns','rows');

		my @rowstats=();
		foreach my $y (0..($h-1)) {
			my @p=$img->GetPixels(
				height=>1,
				width=>$w,
				x=>0,
				y=>$y,
				normalize=>"true",
				map=>"RGB",
			);
			my $sum=0;
			foreach(@p) {
				$sum+=$_;
			}
			$sum/=3;
			$rowstats[$y]=$sum;
			if(!defined($minrow) && $sum>0) { $minrow=$y; }
		}
		for(my $x=$#rowstats; $x>=0; --$x) { # search from right
			if(!defined($maxrow) && $rowstats[$x]>0) { $maxrow=$x+1; }
		}

	}
	my $rowdiff=$maxrow-$minrow;


	# normalize first char position to be aligned at (0,0)
	my @plist; # list of first-letter position probabilities
	LLOOP:
	foreach my $l (@letters) {
		my $needle=$digits{$l};
		my $np=$letterbytes{$l};
		my $ns=[$needle->Get('columns','rows')];
		my @xlist=(0..2);
		for(my $y=0; $y<=$rowdiff-$ns->[1]; ++$y) {
			foreach my $x (@xlist) {
				my @hp=$img->GetPixels(
					width=>$ns->[0],
					height=>$ns->[1],
					x=>$mincol+$x,
					y=>$minrow+$y,
					normalize=>"true",
					map=>"RGB",
				);	
				my $p=compare_ps(\@hp, $np);
				next if $p<0.87;
#				print "$l $x $y $p\n";
				push(@plist, [$x,$y,$p]);
				last LLOOP if $p>0.92;
			}
		}
	}
	my $maxp;
	my $maxe;
	foreach my $e (@plist) {
		my ($x,$y,$p)=@$e;
		if(!$maxp || $p>$maxp) {$maxp=$p;$maxe=$e}
	}
	if($maxe) {
		my ($x,$y)=@$maxe;
		$minrow+=$y; $rowdiff-=$y;
		$mincol+=$x; $coldiff-=$x;
	}

#	print "$w $h $minrow $maxrow $rowdiff\n";
	$img->Crop(x=>$mincol, y=>$minrow, height=>$rowdiff, width=>$coldiff);
#	print $img->Get('columns','rows'),"\n";
}


# returns probability of 2 pixel-arrays matching 
sub compare_ps($$)
{
	my($p1,$p2)=@_;
	my $sum;
	if($#$p1 != $#$p2) {die "coder error: different RGBa types"};
	my $maxsum=0;
	for(my $i=$#$p1; $i>=0; $i-=1) {
		my $val=(($p2->[$i])?2:1); # if needle is bright it counts double
		$maxsum+=$val;
		$sum+=($p1->[$i]==$p2->[$i])?$val:0;
	#	print "$p1->[$i] $p2->[$i]\n";
	}
	return $sum/$maxsum;
}


# returns the most likely positions with probability or undef if probability<threshold
sub find_img($$$)
{	my($haystack,$needle,$np)=@_;
	my $threshold=0.88; # we have 100 pixels to match, 10 being distorted by horiz line and some random dark pixels
	my @res=();
	my $ns=[$needle->Get('columns','rows')];
	my $hs=[$haystack->Get('columns','rows')];
	my @xlist;
	foreach(0..($totalchars-1)) {push(@xlist, $_*$fontsize)};
	for(my $y=0; $y<=$hs->[1]-$ns->[1]; ++$y) {
	#	for(my $x=0; $x<=$hs->[0]-$ns->[0]; ++$x) {
		foreach my $x (@xlist) { # optimization because only certain positions occur
			my @hp=$haystack->GetPixels(
				width=>$ns->[0],
				height=>$ns->[1],
				x=>$x,
				y=>$y,
				normalize=>"true",
			);	
			my $p=compare_ps(\@hp, $np);
			next if $p<$threshold;
			#print "$x $y $p\n";
			push(@res, [$x,$y,$p]);
		}
	}
	return \@res;
}

sub process_awimg($)
{
	my $img=shift;
#	$img->Set(type=>"TrueColorMatte");
	narrow_text($img);
	my @candidate=();
	foreach my $n(@letters) {
		my $a=find_img($img, $digits{$n}, $letterbytes{$n});
		next if not $a || not $a->[0];
		foreach my $e (@$a) {
			my($x,$y,$p)=@$e;
			my $pos=$x/$fontsize;
	#		print "found $n at $pos $x,$y: $p\n";
			push(@{$candidate[$pos]}, [$n,$p]);
		}
	}
	# now make up string from our detected probabilities
	my $string="";
	for(my $i=0; $i<$totalchars; ++$i) {
		my $a=$candidate[$i];
		my ($best,$bestp);
		foreach my $e (@$a) {
			my($n,$p)=@$e;
			if(!defined($bestp) || $p>$bestp) { $bestp=$p; $best=$n; }
		}
		$string.=$best;
	}
	return $string;
}

sub read_awimg($)
{
	my($f)=@_;
	my $img = new Image::Magick;
	$img->Read($f);
#	print "input: $f\n";
	process_awimg($img);
}

# module init
{
	foreach my $n(@letters) {
		my $d = new Image::Magick;
		$d->Read("/home/aw/base/awread/digits/$n.png");
		$digits{$n}=$d;
		my @xy=$d->Get('columns','rows');
		$letterbytes{$n}=[$d->GetPixels(
			width=>$xy[0],
			height=>$xy[1],
			x=>0,
			y=>0,
			normalize=>"true",
			map=>"RGB",
		)];

	}
}

1;
