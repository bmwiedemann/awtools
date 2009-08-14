use strict;
use MLDBM qw(DB_File Storable);
use Fcntl;
use DBAccess;
use awstandard;
use awinput;
# TODO: cleanup to not use awinput::planets directly

my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

sub filter() {
	my $data=getparsed(\%::options);
   return if(!$data->{name} || !$::options{url});
   return if($ENV{REMOTE_USER} eq "xr"); # TODO : drop later?
   my ($sysname,$x,$y)=($data->{name},$data->{x},$data->{y});
   my $sid=systemcoord2id($x,$y); #systemname2id($sysname);
   if ($::options{url}=~m/\?nr=(\d+)/) {$sid=$1}
   my @system=systemid2planets($sid);
#   return if ! @system;
   print qq!update on <a href="system-info?id=$sid">$sysname</a> ($x,$y)<br>\n!;
   m/Population.*?Starbase.*?Owner(.*)/s;
   $_=$1;

   untie %awinput::planets;
   tie %awinput::planets, "MLDBM", "db/planets.mldbm", O_RDWR|O_CREAT, 0666 or print "can not write DB: $!";

	my $planets=$data->{planet};
	foreach my $pla (@$planets) {
      my ($siege,$pid,$pop,$sb,$playerid,$owner)=($pla->{sieged}, $pla->{id}, $pla->{population}, $pla->{starbase}, $pla->{pid}, $pla->{name});
		next if not defined $playerid; # skip missing planets
      if($pop==0) {$pop++}
      my $details="$pid $pop $sb $siege $owner";
      my $p=$system[$pid-1]; #getplanet($sid,$pid);
		if(!$p) {
			$details.=" new entry $pid ";
			$system[$pid-1]=$p={opop=>,$pop, planetid=>$pid, systemid=>$sid};
		} else {
			$details.=" old: ".planet2pop($p)." ".planet2sb($p)." ".planet2siege($p);
			print "$details<br>\n";
		}
		$$p{s}=$siege;
		$$p{ownerid}=$playerid;
		$$p{pop}=$pop;
		$$p{sb}=$sb;
# additionally update in mysql DB:
      my $sidpid=sidpid22sidpid3m($sid,$pid);
		my $sth=$dbh->prepare("INSERT INTO `planets` VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE population=?, starbase=?, ownerid=?, siege=?");
      $sth->execute($sidpid, $pop, $pop, $sb, $playerid, $siege,
			$pop, $sb, $playerid, $siege);
   }
   if(!$debug) {
      $awinput::planets{$sid}=\@system;
   }
   untie %awinput::planets; # flush write buffers and avoid unwanted later modifications
}

filter();

1;
