#!/usr/bin/perl

use strict;
use Time::Local;
require 'input.pm';
my $cleantime=7; # hours
my $ecleantime=24*5; # hours
#my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-planets.dbm";

sub test_age { my ($name, $dayname, $mon, $day, $hour, $min, $sec, $year)=@_;
   my @rel=getrelation($name);
	my $date=timegm($sec,$min,$hour,$day, mon2id($mon), $year);
	my $wday=(gmtime($date))[6];
	my $age=time-$date;
	if(($dayname eq $::weekday[$wday]) && (!$rel[0] || $rel[0]>4 || ($age>3600*$ecleantime)) && $age>3600*$cleantime) { return ""}
	return $&;
}

my %plinfo=%::planetinfo;
dbfleetaddinit(undef);
while((my @a=each %plinfo)) {
  #print "$a[0] \n";
  my $p=$a[1];
  $a[1]=~s/$::magicstring([^:]+):(...) (...)\s+(\d+) (\d\d):(\d\d):(\d\d) (\d+) (?:\d+\s*){5}(?:\s*\d+CV)?\s*/test_age($1,$2,$3,$4,$5,$6,$7,$8,$9)/ge;
#	print $a[0]," ",time-timegm($7,$6,$5,$4,mon2id($3),$8),"\n";
  if($a[1] ne $p || $p=~/^5 /s) {
  	#print "$p -> $a[1]\n";
#  	my %data;
#	tie(%data, "DB_File", $dbname) or die "error accessing DB\n";
	if($a[1]=~/^\d+ \d+\s*$/s) { delete $::planetinfo{$a[0]} }
	else { $::planetinfo{$a[0]}=$a[1]; }
#	untie(%data);
  }
}
dbfleetaddfinish();
