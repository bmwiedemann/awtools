use strict;
use awparser;

($d->{title})=(m{<html><head><title>([^<>]* - profile - Astro Wars)</title>});
($d->{name})=($d->{title}=~m{^([^<>]*) - profile - Astro Wars$});

my @planets=();
foreach my $line (m{<tr.(.+?)</td></tr>}gs) {
	if($line=~m{^bgcolor="#303030" align=center><td>}) {
		my @a=split("</td><td>",$');
		my @label=qw(n sid pid pop cv);
		my %a=();
		for my $n(0..4) {$a{$label[$n]}=$a[$n]}
		push(@planets, \%a);
	} elsif($line=~m{^<td bgcolor="?#202020"?>}) { # parse key-value pairs
		my @a=split("</td><td[^>]*>",$');
		my $k=lc(shift(@a));
		$k=~s/[^a-z]//g;
		my $v=shift(@a);
		if($k eq "playsfrom" && $v=~m{<img src="/images/flags/(\w+)\.png"}) {
			$v=$1;
		} elsif($k eq "origin" && $v=~m{^<a href ="/about/starmap\.php\?dx=(-?\d+)&dy=(-?\d+)">go to starmap</a>$}) {
			$v={x=>$1, y=>$2};
		} elsif($k eq "icq" && $v=~m{^<a href="http://wwp.icq.com/(\d+)">}) {
			$v=$1;
		}
		$d->{$k}=$v;
	} elsif($line=~m{^bgcolor=#404040 align=center><td colspan=3> Points: }) {
		my @a=split("</td><td>",$');
		my @b=split("[+=]",shift(@a));
		$d->{points}={pop10=>shift(@b), pl=>shift(@b), science=>shift(@b), total=>shift(@b), "pop"=>shift(@a), "cv"=>shift(@a)};
	} elsif($line=~m{^bgcolor=#202020><td colspan=2>}) {
		my @a=split("<br>",$');
		$d->{trade}=[map {
				m{id=(\d+)>([^<>]+)</a>$};
				{pid=>$1, name=>$2};
		    } @a];
	} elsif($line=~m{^<td colspan="2" align="center" bgcolor="#303030"><b>\s*(?:<font color="#FFCC00">)?<a href=/rankings/alliances/(\w+)\.php>}) {
		$d->{tag}=$1;
		my $post=$';
		if($post=~m{ \((\d+)(?:th|rd|nd|st)\)</font></b>$}) {
			$d->{permanentrank}=$1;
		}
		if($post=~m{<small>Premium Member</small>}) {
			$d->{premium}=1;
		}
	} elsif($line=~m{^<td colspan="2"><a href=http://www\.astrowars\.com/forums/privmsg\.php\?mode=post&u=(\d+)>Send Private Message</a>$}) {
		$d->{pid}=int($1);
	} elsif($line=~m{^align="center" bgcolor="#181818"} || $line=~m{^bgcolor="#402525"} || $line=~m{^<td>\s*<b>About<br>}) {
	} else {
		# TODO a lot
		$d->{debug}=$line;
	}
}
$d->{planet}=\@planets;

2;
