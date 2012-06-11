#!/usr/bin/perl -w
use strict;
use Email::Simple;
use lib "/home/aw/inc";

local $/;
my $text=<>;
my $email = Email::Simple->new($text);

my $from_header = $email->header("From");
my $ret_header = $email->header("Return-Path");
my $to_header = $email->header("To");
my $subject_header = $email->header("Subject");
my $body = $email->body;

my $verify=($text=~m/Received: from mx.\....\.paypal\.com \(mx.\..*paypal.com/);
if($ret_header ne '<payment@paypal.com>') {$verify=0} # disable for test/debug

my $extract="";
if($subject_header=~m/Artikelnr. (AW-.*) - PayPal-Zahlung von (.*) erhalten/) {
	$extract.="$1 $2 ";
} else {$verify=0}

my $alli="";
if($body=~m/Artikelnummer:AW-.* , Info: (\w+)\s*, AW Name: (.*)/) {$alli=$1; $extract.="$1 $2 "}

if($verify && $alli) {
	$alli=lc($alli);
	# add alli
	chdir("/home/aw/inc");
	system("./paidaw", $alli);
}

open(F, ">>/tmp/paypalmailreceiver") or die $!;
print F "$verify $ret_header $from_header $to_header $subject_header\nextract: $extract\n\nbody: $body\n";
close F;

