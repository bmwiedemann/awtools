#
# manage PL history for AW
#
package dbaddpl;
use strict;
use warnings;
use awinput;
use DBAccess;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(dbaddpl);

sub dbaddpl($$$) { my($t,$name,$pl)=@_;
   if(!$pl || !$name) {return 0}
#   open(F, ">>", "/tmp/aw-pl.log") or die $!;
#   print F "$t $name $pl\n";
#   close F;

   my $pid=playername2id($name);
   if(!$pid) {return 0}

   my $sth=$dbh->prepare("SELECT * FROM `plhistory` WHERE `pid` = ? AND `pl` = ? AND `alli` = ?");
   my $res=$dbh->selectall_arrayref($sth, {}, $pid, $pl, $ENV{REMOTE_USER});
   if($res && $$res[0]) { # already found
      return 0;
   }
   $sth=$dbh->prepare("INSERT INTO `plhistory`  VALUES (?, ?, ?, ?)");
   my $alli=$ENV{REMOTE_USER}||"";
   $sth->execute($t, $pid, $pl, $alli);
}

1;
