#!/usr/bin/perl -w
use strict;
use Email::Simple;
use lib "/home/aw/inc";
use awstandard;
use LWP::Simple;


local $/;
my $text=<>;
my $email = Email::Simple->new($text);

my $from_header = $email->header("From");
my $ret_header = $email->header("Return-Path");
my $to_header = $email->header("To");
my $subject_header = $email->header("Subject");
my $body = $email->body;

my $verify=($text=~m/Received: from www1\.astrowars\.com \(www1.astrowars.com \[87\.106\.23\.19\]\)\s+by .*\.zq1\.de \(Postfix\) with ESMTP/);
if($ret_header ne '<automailer@astrowars.com>' or $from_header ne 'automailer@astrowars.com') {$verify=0}

my @data=("AW incoming");
if($subject_header=~m/Incoming Fleet Warning (\w{3} \d+ - [0-9:]+) CV:(\d+)/) {
	my($date,$cv)=($1,$2);
	my $t=parseawdate($date);
	$date=AWisodatetime($t);
	push(@data, "date=$date", "cv=$cv");
} else {$verify=0}

if($body=~m/^ going to attack (.*?) (\d+)! We suppose its the fleet of (.*?)\.$/m) {
	push(@data, "target=$1#$2", "owner=$3");
} else {$verify=0}

my $transports=0;
if($body=~m/<br>(\d+) Transports/) {$transports=$1; push(@data, "trn=$transports");}

my $extract=join(" ", @data);
my $pnum="01782844867";
my $url="http://s6.dove.mikrom.com:6080/sendsms.pl?p=$pnum&text=".url_encode($extract);
my $smssend="";
if($verify && $transports) {
	$smssend=get($url);
}

open(F, ">>/tmp/awmailreceiver") or die $!;
print F "$verify $ret_header $from_header $to_header $subject_header\nextract: $extract\nurl=$url\nsms=$smssend\nbody: $body\n";
close F;

