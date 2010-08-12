package typocheck;
use strict;
use utf8;
#use Encode;
use DB_File;

my $dbname="wordcount.dbm";
our %data;
sub init()
{
	tie(%data, "DB_File", $dbname, O_RDONLY) or die "error opening DB: $!";
}


sub get_wordcount($)
{
	my $l=lc($_[0]);
	utf8::encode($l);
	return ($data{$l}||0);
}

my @goodcount=(1000,200,80,20,8,7,6);

sub check_composite($;$);
sub check_composite($;$)
{
	my($word,$depth)=@_;
	$depth||=0;
	if($depth>1 || length($word)<8) {return 0}
	my $maxscore=0;
	for my $n (3..30) {
		last if $n>length($word)-3;
		my $w1=substr($word,0,$n);
		my $w2=substr($word,$n);
		my $c1=get_wordcount($w1);#+check_composite($w1,$depth+1);
		my $c2=get_wordcount($w2);
		my $w3=$w1;
		my $c3=0;
		if($w3=~s/s$// && ($c3=get_wordcount($w3))>$c1) {
			$c1+=$c3;
			$w1="$w3+s"; 
		}
		my $score=$c1*$c2;
		next if $score<30;
		if($score>$maxscore) {$maxscore=$score}
#		print "$w1=$c1 $w2=$c2\n";
		last if $score>1000000
	}
	return sqrt($maxscore);
}

sub simitestclient($)
{
	my($str)=@_;
	require IO::Socket;
	my $sock=IO::Socket::INET->new(PeerAddr=>"delta.zq1.de:6987", Timeout=>2) or return (); # die "error opening socket: $!";
	print $sock $str,"\n";
	my @res;
	local $_;
	while(<$sock>) {
		chop;
		last if($_ eq "");
		push(@res, [split(" ", $_)]);
	}
	return @res;
}

sub strdiff2html($$)
{
	my($bad,$good)=@_;
	return "" unless my @a=("$bad\n$good" =~m/^(.+)(.*?)(.+)\n\1(.*)\3$/);
	return qq'$a[0]<span class="badpart">$a[1]</span>$a[2] =&gt; $a[0]<span class="goodpart">$a[3]</span>$a[2]';
}


sub checkword($)
{
	my($word)=@_;
	return 0 if $word eq "";
	my $count=get_wordcount($word);
	my $goodcount=$goodcount[length($word)-1]||5;
	return 0 if $count>$goodcount;
	return 1 if length($word)<8;
	$word=lc($word);
	# wortkompositionen
	my $composcore=check_composite($word);
	if($composcore>150) {return 0} # 1000 produces many false positives
#	print "$word=$count $composcore\n";
	return 1;
}

sub split_words($)
{
	my $x=shift;
	return [split(/[^a-zA-ZäöüÄÖÜßáÁâąĄåÅÂæÆćĆčČçÇďĎëËéÉěĚęĘėĖíÍïÏîÎłŁĺĹńŃňŇñÑóÓøØœŒřŘśŚšŠťŤúÚůŮýÝźŹżŻž]+/, $x)];
}

sub stripwiki($)
{
	local $_=shift;
	s{<ref [^><\]]+>}{ }g;
   s{http://[^ "><\]]+}{}g;
   s/'''?//g; # drop bold/italic
   s/\[\[[a-z-]{2,11}:[^\]]+\]\]/ /g; # drop foreign language links
	s/\[\[(?:Bild|Image):[^|\]]+/ /g; # drop image links
	s/[\[\]]//g; # drop wikilink markers to merge words
	return $_;
}

# use encoding "utf8";
sub checktext($)
{
   my $a=split_words(stripwiki(shift));
#	print;
#	binmode STDOUT, ":utf8";
	my @out;
   foreach my $w (@$a) {
      next if not $w;
      my $error=checkword($w);
		if($error) {
			push(@out,"$w");
			if(length($w)>4) {
				my @res=simitestclient(lc($w));
				my $n=$#res; if($n>3){$n=3}
				@res=@res[0..$n]; # only take most common 4 hits
				foreach my $b (@res) {
					my($str,$count,$s)=@$b;
					push(@out, typocheck::strdiff2html(lc($w), $str)." $count $s<br />");
				}
			}
		}
   }
	return @out;
}

sub countmatches(@)
{
	my($re)=@_;
	my $count=[];
	for(my $n=$#$re; $n>=0; --$n) {$count->[$n]->{match}=0}
	while(my @a=each(%data)) {
#		print "@a\n";
		my $n=0;
		utf8::decode($a[0]);
		foreach my $r (@$re) {
			my $c=$count->[$n++];
			next if($a[0]!~m/$r/);
			$c->{match}++;
			$c->{count}+=$a[1];
		}
	}
	return $count;
}

sub finish()
{
	untie(%data);
}

1;
