use strict;
use DBAccess;
use awinput;

if($ENV{REMOTE_USER} || $::options{name} eq "greenbird") {
   my $now=time();
   sub addetc($) { my($name)=@_;
      my $etc=awinput::playername2etc($name);
      if(!$etc || (($etc-$now)<-150*3600)) {$etc="-"}
      else {$etc-=$now;$etc=sprintf("%.1fh",$etc/3600)}
      return $etc;
   }
   sub addidle($) { my($name)=@_;
      my $sth=$dbh->prepare_cached("SELECT lastclick 
   FROM usersession 
   WHERE name = ?
   ORDER BY lastclick DESC
   LIMIT 1");
      my $res=$dbh->selectall_arrayref($sth, {}, $name);
      if($res && $$res[0]) {
         my $t=int(($now-$$res[0][0])/60);
         return " / ".$t."m";
      }
      return "";
   }

   s%(<td colspan=)3(>Trade</td>)%${1}4$2%;
   s%(<td>Idle</td>)</tr>%$1<td>ETC</td></tr>%;
   my $tdre=qr/<td>(?:<font color=#80b0b0>)?[^<]*(<\/font>)?<\/td>/;
   s/(<tr align=center bgcolor=#303030 [^>]*><td><a href=[^>]*>)([^<]*)(<\/a>(?:<img src=[^>]*>)?<\/td>$tdre{12}<td>[^<]*)/$1.$2.$3.addidle($2)."<\/td><td>".addetc($2)/ge;
#   $_.="notice: this filter is new. It adds time since last click and ETC (Estimated Time to Culture)";

}

1;
