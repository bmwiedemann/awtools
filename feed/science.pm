#exit 0; # partial energy no more needed
use strict;
#use CGI ":standard";
use awstandard;
use awinput;
use DBAccess2;
my $data=getparsed(\%::options);

my $debug=$::options{debug};
if($debug) {print "debug mode - no modifications done<br>\n"}

my $name="\L$::options{name}";
#print a({-href=>"relations?name=$name"}, $::options{name}).br();


my @science;
foreach my $sci (@awstandard::sciencestr) {
	my $sl=$data->{lc($sci)}{level};
      if($debug) {
         print "$sci: $sl\n<br>";
      }
		push(@science, $sl); #trade bonus unknown - but we push undef here anyway
}

if($data->{etc}) {
   my $etc=$data->{etc};#time()-$::deliverytime+($a[0]*60+$a[1])*60+$a[2];
   push(@science,$etc);
   print " ETC: ".AWtime($etc).br();#" @a\n<br>";
}
# calc ETC for > 3 days
{
   my ($culperh,$culbonus)=(int($data->{cultureplus}{hourly}),$data->{cultureplus}{bonus});
#   awdiag("$::options{name} $culperh $culbonus");

   if($ENV{REMOTE_USER} && $::options{pid}) {
#      href="/0/Glossary//?id=20"><b>Science</b></a> <a class="awglossary" href="/0/Glossary//?id=23">(+626 per hour)</a>
      my $sciperh=int($data->{scienceplus}{hourly});
	use JSON::XS; print encode_json($data), "science=$sciperh";
      my $dbh=get_dbh();
      my $sth=$dbh->prepare("INSERT INTO `internalintel` (alli,pid,modified_at,science,culture) VALUES (?,?,UNIX_TIMESTAMP(),?,?) ON DUPLICATE KEY UPDATE `science`=VALUES(science), `culture`=VALUES(culture), modified_at=UNIX_TIMESTAMP()");
#      my $sth=$dbh->prepare("INSERT INTO `internalintel` (alli,pid,science,culture) VALUES (?,?,?,?) UPDATE `internalintel` SET `culture`=?, `science`=? WHERE `alli`=? AND `pid`=?");
		#$sth->execute($ENV{REMOTE_USER}, $::options{pid}, $sciperh, $culperh); # disabled 2013-03-25 because values included boni
   }
   
   if(@science<9) {
      $culbonus=~s/.*([+-]\d+).*/$1/;
      $culbonus||=0;
      $culbonus=1+$culbonus/100;
#print "cul: $culperh,$culbonus<br>";
      if($culperh && m!Culture.*/images/leer.gif" height="10" width="\d+"></td><td>(\d+)<!) {
         my $culleft=$1;
         my $etc=time()-$::deliverytime+$culleft*3600/($culperh*$culbonus);
         print $culleft*3600/($culperh*$culbonus).br();
         print " ETC: ".gmtime($etc).br();
         push(@science,$etc);
      }
   }
}

#our %relation;
#tie(%relation, "DB_File", $dbname) or print "error accessing DB\n";
#my $oldentry=$relation{$name};
dbplayeriradd($name,\@science);
#if($debug){ print "$oldentry @science new:$newentry\n<br>" }
#else {$relation{$name}=$newentry}
#untie %relation;


1;
