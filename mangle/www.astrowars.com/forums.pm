use strict;
use DBAccess2;
my $dbh=get_dbh;
my $sth=$dbh->prepare_cached("SELECT `forumstyle` FROM `playerprefs` WHERE `pid` = ? LIMIT 1");
my $res=$dbh->selectall_arrayref($sth, {}, $::options{pid});
if($res && $res->[0] && (my $s=$res->[0]->[0])) {
# replace forum theme
   $s=~s/ +$//;
   if($s) {
	   s{(["(]templates)/subBlack/subBlack} {$1/$s/$s}gi;
	   s{(["(]templates)/subBlack/} {$1/$s/}gi;
   }
}

1;
