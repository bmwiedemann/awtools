use strict;
use DBAccess;
use awinput;

s%<td>([A-Za-z]{2,3}) ([1-3])</td>%<td>$1&nbsp;$2</td>%g;

if($ENV{REMOTE_USER}) {
   my $now=time();
   sub addetc($) { my($name)=@_;
      my $etc=awinput::playername2etc($name);
      require "sort_table.pm";
      return sort_table::display_etc($etc);
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
         return "&nbsp;/&nbsp;".$t."m";
      }
      return "";
   }

	s%Idle</a></th>%$&\n<th>ETC</th>%;
	s%Artifact">A</a></th>\s*<th scope="col"></th>%$&\n<th scope="col"></th>%;
   my $tdre=qr/<td>(?:<span[^<>]*>)?[^<]*(<\/span>)?<\/td>\s*/;
   s/(<tr[^>]*>\s*<td><a href=[^>]*>)([^<]*)(<\/a>(?:<img src=[^>]*>)?<\/td>\s*$tdre{12}<td>[^<]*)/$1.$2.$3.addidle($2)."<\/td><td>".addetc($2)/ge;
#   $_.="notice: this filter is new. It adds time since last click and ETC (Estimated Time to Culture)";
}

2;
