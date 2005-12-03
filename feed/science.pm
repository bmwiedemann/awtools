#exit 0; # partial energy no more needed
use strict;

my $debug=$::options{debug};
print "science feed\n<br>";
if($debug) {print "debug mode - no modifications done<br>\n"}

#my $dbname="/home/bernhard/db/$ENV{REMOTE_USER}-relation.dbm";
require "input.pm";
my $name="\L$::options{name}";
print a({-href=>"relations?name=$name"}, $::options{name}).br();


my @science;
foreach my $sci (@::sciencestr) {
	if(m!$sci</a> </td><td>(\d+)</td><td><img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"!) {
		my $sl=$1;#+($2/($2+$3));
      if($debug) {
         print "$sci: $sl $1 $2 $3\n<br>";
      }
		push(@science, $sl);
	}
}
push(@science,undef); #trade bonus unknown
if(my @a=m!Culture</a>.*INPUT type="text" value="(\d+):(\d+):(\d+)" size="8" name="z" class=text!) {
   my $etc=time()-$::deliverytime+($a[0]*60+$a[1])*60+$a[2];
   push(@science,$etc);
   print " ETC: ".AWtime($etc).br();#" @a\n<br>";
}
# calc ETC for > 3 days
if(@science<9 && m!href="/0/Glossary//\?id=23">\(\+(\d+) per hour\)</a> <b>([+-]\d+)%!) {
   my ($culperh,$culbonus)=($1,1+$2/100);
#print "cul: $culperh,$culbonus<br>";
   if(m!Culture.*/images/leer.gif" height="10" width="\d+"></td><td>(\d+)<!) {
      my $culleft=$1;
      my $etc=time()-$::deliverytime+$culleft*3600/($culperh*$culbonus);
      print $culleft*3600/($culperh*$culbonus).br();
      print " ETC: ".gmtime($etc).br();
      push(@science,$etc);
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
