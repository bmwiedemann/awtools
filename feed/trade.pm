use DBAccess2;
my $data=getparsed(\%::options);

my($ad)=$data->{Astro_Dollars_ad};
my($tr)=$data->{Trade_Revenue};
my($sus)=$data->{Supply_Units};
$sus=~s%(\d+)/\d+%$1%;

if($::options{pid} && defined($ad)) {
   my $dbh=get_dbh();
   my $sth=$dbh->prepare("UPDATE `internalintel` SET `tr`=?, `ad`=?, `sus`=? WHERE `alli`=? AND `pid`=?");
   $sth->execute($tr, $ad, $sus, $ENV{REMOTE_USER}, $::options{pid});
}

1;
