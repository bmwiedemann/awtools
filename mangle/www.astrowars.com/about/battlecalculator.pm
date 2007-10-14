use strict;
use DBAccess2;

# add proper URLs
s/(form action="" method=")post/$1get/;
s%</td></tr></table>%$&<a style="color:green" href="$::options{url}">Link to this page</a>%;



# add in+out to DB:

my %pmap=qw(
des ds1
destroyer ds2
cru cs1
cruiser cs2
bat bs1
battleship bs2
sta sb
pphysics ph1
fphysics ph2
pmath ma1
fmath ma2
plevel pl1
flevel pl2
praceatt at1
fraceatt at2
pracedef de1
fracedef de2
);
(my $p=$::options{url})=~s/.*\?//;
my $cgi=CGI->new($p);
my %values=();
foreach my $e ($cgi->param()) {
   my $p2=$pmap{$e};
   next if not $p2;
#   $_.=" $p2=".$cgi->param($e);
   $values{$p2}=$cgi->param($e);
}
if(m%Race Mod Attack</td>(.*)Race Mod Defense</td>(.*)Chance to win</td><td colspan="2">([0-9.]+)%s) {
   my ($att,$def,$chance)=($1,$2,$3);
   my @att=$att=~m!^(.{0,10})</td>!gm;
   my @def=$def=~m!^(.{0,10})</td>!gm;
   foreach my $v (@att,@def) {
      $v+=100; # includes numerifying and stripping "%"
   }
   $values{att1}=$att[0];
   $values{att2}=$att[1];
   $values{def1}=$def[0];
   $values{def2}=$def[1];
   $values{chance}=$chance;
#   $_.="\n\n@att\n\n@def\n\n$chance";
}
#$_.=$p;

#my @kill;
my @killr;
my @oships;
foreach my $s (qw(des destroyer cru cruiser bat battleship sta)) {
   my($left)=m!input type="text" name="$s" size="5" value="\d+" class=text></td><td>([0-9.]*)</td>!;
   my $p2=$pmap{$s};
   next if not $values{$p2};
   my $n=0;
   if($p2=~m/\d$/) {
      $n=$&-1;
   }
   my $kill=$values{$p2}-$left;
   if(!$oships[$n] || $values{$p2}>$oships[$n]) {
      $oships[$n]=$values{$p2};
#   if(!$kill[$n] || $kill>$kill[$n]) { 
#      $kill[$n]=$kill;
      $killr[$n]=$kill/$values{$p2}
   }
}
$values{kill1}=$killr[0];
$values{kill2}=$killr[1];
#$_.="@kill @killr";
my $dbh=get_dbh;
my @str;
my @param;
while((my @a=each(%values))) {
   push(@str,"$a[0]=?");
   push(@param, $a[1]);
}
#$_.="@str @param";
if($killr[0] && $killr[1]) {
   my $sth=$dbh->prepare("REPLACE INTO `battlecalc` SET ".join(", ",@str).", modified_at=?");
   $sth->execute(@param, time());
}

# bugfix for AR:
# show SB as float again
my $sb=$cgi->param("sta");
if($sb != int($sb)) {
   $sb=~s/[^0-9.+-]//g;
   s%(<a href=/portal/Starbase>Starbase</a></td><td><input type="text" name="sta" size="5" value=")\d+(" class=text>)%$1$sb$2%;
}

1;
