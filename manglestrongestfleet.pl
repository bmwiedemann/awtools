#!/usr/bin/perl
use strict;
BEGIN {$ENV{REMOTE_USER}="guest";}
use awstandard;
use awinput;
awinput_init();

my $sname="strongestfleet";
my $fleetfile=shift();
my $guardedfile=shift();
my %fleets=();

open(FILE, "<", $fleetfile) or die $!;

$/=undef;
$_=<FILE>;
my $orig=$_;
$orig=~s!</title>!$&<base href="http://www1.astrowars.com/rankings/">!;
my $links=qq!<a href="http://aw.lsmod.de/cgi-bin/index.html">AWtools index</a> !;
for my $i (1..5) {
	$links.=qq!<a href="http://aw.lsmod.de/$sname-$i.html">$i</a> !;
}
#$orig=~s!not counted\)<br>!$&$links<br>!;
$orig=~s!<b>Strongest available!$links<br>$&!;
$orig=~s!Battleship</a></td>!$&<td><a href="http://www.astrowars.com/portal/CV">CV</a></td>!;

my @a;
for(;(@a=m!<tr[^>]*><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td>(\d+)</td><td><a [^>]*>([^<]+)</a>(.*)!); $_=$a[5]) {
   my $n=$a[0];
   my @fleet=(0,0,@a[1..3]);
	my $name=$a[4];
	my $cv=fleet2cv(\@fleet);
	#print "fleet @a[0..2] '$name' = $cv CV\n";
#	$fleets{$cv}=\@a[0..3];
	my $plid=playername2id($name);
	if(!$plid) { next }
	my $atag="";
	my $aid=getplayer($plid)->{alliance};
	if($aid) {$atag=allianceid2tag($aid);}
	#print "aid $aid $atag $plid\n";
	#my @rel=getrelation($name);
	#my $atag=$rel[1]||"";
   $orig=~s!<td>$n</td><td>$fleet[2]</td><td>$fleet[3]</td><td>$fleet[4]</td>!$&<td>$cv</td>!g;
	$orig=~s!\Q$name</a>!$name [$atag]</a>!;
}

open(OUT, ">", "html/$sname-1.html") or die $!;
print OUT $orig;


open(FILE, "<", $guardedfile) or die $!;
$_=<FILE>;
for(;(@a=m!<tr[^>]*><td>\d+</td><td[^>]*><a [^>]*>([^<]+) (\d+)</a></td><td>(\d+)</td><td><a [^>]*>([^<]+)</a>(.*)!); $_=$a[4]) {
	my ($system,$planet,$totcv,$name)=@a[0..3];
	$system=systemname2id($system);
	if(!$system) {next}
	my $sid="$system#$planet";
	my $p=sidpid2planet($sid);
	if(!$p) {next}
	my $sb=planet2sb($p);
	my $cv=sb2cv($sb);
	my $fleetcv=$totcv-$cv;
	#print "guard @a[0..3] $sid $sb $cv $fleetcv\n";
}

