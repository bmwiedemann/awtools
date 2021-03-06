#!/usr/bin/perl -w
use strict;
use DBAccess;
use awstandard;
my $oldname=readlink "html/round";#"gold18";
my $newname=$oldname;
$newname=~s/(\d+)$/1+$1/e;
my $newround=1;

if($newround) {
   mkdir "html/$newname";
   unlink("html/round");
   symlink($newname, "html/round");
   system("touch", "html/round/paid");
   chmod(0666, "html/round/paid");
   foreach(qw"player alliances") {
      system("cp -a csv/$_.csv csv/$_.csv.$oldname");
   }
#   system("ssh root\@awdb cp -a /var/lib/mysql/astrowars /var/lib/mysql/astrowars_$oldname");
#	if($?>>8) {die "backup failed";}
}
system("./updatelasttag.pl");
$dbh->do("UPDATE playerextra SET premium=NULL");
$dbh->do("UPDATE planets SET ownerid=0");
$dbh->do("UPDATE intelreport SET racecurrent=0");
$dbh->do("UPDATE intelreport SET biology=NULL, economy=NULL, energy=NULL, mathematics=NULL, physics=NULL, social=NULL");
foreach my $name (qw(alliaccess cdcv cdlive alltrades trades battles fleets plhistory planetinfos player useralli internalintel internalplanet logins tradelive)) {
   $dbh->do("TRUNCATE TABLE `$name`");
}

$dbh->do("DELETE  FROM `toolsaccess` WHERE `rbits` != 255 AND tag != ''");
$dbh->do("UPDATE toolsaccess SET flags=0");
$dbh->do("UPDATE toolsaccess SET flags=3 WHERE tag = 'af'");

system("make cleanmap2");
#system("cat empty.dbm > $awstandard::dbmdir/useralli.dbm");
#system("cat empty.dbm > $awstandard::dbmdir/points.dbm");
system("perl -i.bak -pe 's/(round=.?)$oldname/\$1$newname/' Makefile");
#system("for f in $awstandard::dbmdir/*planets.dbm ; do cat empty.dbm > \$f ; done");
system("for f in $awstandard::dbmdir/*relation.dbm ; do ./clear.pl \$f ; done");

awstandard::set_file_content("csv/alltrades.csv", "id1\tid2\n");
awstandard::set_file_content("html/alltrades.csv", "id1\tid2\n");
awstandard::set_file_content("csv/player.csv", "rank\tpoints\tid\tscience\tculture\tlevel\thome_id\tlogins\tfrom\tjoined\talliance\tname\ttrade\n");
awstandard::set_file_content("csv/battles.csv", "id\tcv_def\tcv_att\tatt_id\tdef_id\twin_id\tplanet_id\tsystem_id\ttime\n");
awstandard::set_file_content("systemexportsecret", rand(1000000000000000)."\n");

system(qw"/usr/bin/perl -i -pe", '@a=split("\t"); if($notfirst){$a[2]=$a[3]=$a[4]=$a[5]=0} $_=join("\t",@a)."\n"; $notfirst=1', "csv/planets.csv");

system("make importcsv");

for my $l ("log/brownie.log", "log/aw-access_log") {
	rename($l, "$l.$oldname");
	fork || exec "xz", "$l.$oldname" || die; # compress in background
}
# truncate error logs
foreach (qw(aw21-error_log aw2-error_log)) {
	awstandard::set_file_content("log/$)", "");
}
print "check start of new log + reloadhttp\n";

