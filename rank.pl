#!/usr/bin/perl -w

use CGI ":standard";
#$ENV{REMOTE_USER}="af";
require "input.pm";
open ENEMY, "> html/enemies.$ENV{REMOTE_USER}.html" or die $!;

my $dummy=$::relation{greenbird};
my @rankings=();
foreach my $name(keys %::relation) {
	my @rel=getrelation($name);
	if(!defined($rel[0])) {next}
	my $id=playername2id($name);
	next unless $id;
	my $points=$::player{$id}{points};
#	printf("%.3i(%.4i) $name($id)\n",$points,$::player{$id}{rank});
	my $p=$::player{$id};
	if($rel[0]<=3) {
		print ENEMY qq!<a href="/cgi-bin/relations?name=$name">$name ($id)</a><br>\n!;
	}
	if($rel[0]==9) {
		my $entry="";
		foreach my $k (qw"points rank culture science level name") {
			my $v=$$p{$k};
			if($v=~/^\d+$/) {$v=sprintf("%.4i",$v);}
			$entry.="$k=$v ";
		}
		push @rankings, $entry;
	}
}

my $head=AWheader2($ENV{REMOTE_USER}." alliance ranking");
$head=~s!<a href="!$&/cgi-bin/!g;
print $head,"<pre>", join("\n", sort @rankings),"</pre>",end_html();
