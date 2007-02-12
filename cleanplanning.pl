#!/usr/bin/perl

use strict;
use Time::Local;
use awstandard;
use awinput;
awinput_init();

my $cleantime=7; # hours
my $ecleantime=24*5; # hours

sub test_age { my ($name, $dayname, $mon, $day, $hour, $min, $sec, $year)=@_;
   my @rel=getrelation($name);
	my $date=timegm($sec,$min,$hour,$day, mon2id($mon), $year);
	my $wday=(gmtime($date))[6];
	my $age=time-$date;
	if(($dayname eq $awstandard::weekday[$wday]) && (!$rel[0] || $rel[0]>4 || ($age>3600*$ecleantime)) && $age>3600*$cleantime) { return ""}
	return $&;
}

sub test_age2{ my ($year,$mon,$day)=@_;
	my $date=timegm(0,0,0,$day, $mon-1, $year);
   my $age=time-$date;
   if($age>3600*24*4) { return "" }
   return $&;
}

my %plinfo=%planetinfo;
awinput::dbplanetaddinit(2);
while((my @a=each %plinfo)) {
  #print "$a[0] \n";
  my $p=$a[1];
#  $a[1]=~s/$magicstring([^:]+):(...) (...)\s+(\d+) (\d\d):(\d\d):(\d\d) (\d+) (?:\d+\s*){5}(?:\s*\d+CV)?\s*/test_age($1,$2,$3,$4,$5,$6,$7,$8,$9)/ge;
  $a[1]=~s/\btook:(\d{4})-(\d\d)-(\d\d)\b.*/test_age2($1,$2,$3)/ge;
  if($a[1] ne $p) {
#  if($a[1] ne $p || $p=~/^5 /s) {
	if($a[1]=~/^\d+ \d+\s*$/s) { delete $planetinfo{$a[0]} }
	else { $planetinfo{$a[0]}=$a[1]; }
  }
}
dbfleetaddfinish();
