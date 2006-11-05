use awstandard;

#awdiag("planets feeding ".length($_));
#open(F, ">/tmp/)
if(m!Transport</a></td><td>(\d+).* Colony Ship</a></td><td>(\d+).* Destroyer</a></td><td>(\d+).* Cruiser</a></td><td>(\d+).* Battleship</a></td><td>(\d+).*<a href="?/0/Player/Profile.php/\?id=(\d+)"?>Hostile forces in the orbit of ([^\!]*) (\d+)\!!s) {
   my @fleet=($1,$2,$3,$4,$5);
   my ($owner, $sid, $pid) = ($6, systemname2id($7), $8);
#   awdiag("@fleet $6 sieges $sid $pid");
   dbplanetaddinit(undef, 8);
   dbfleetadd($sid, $pid, $owner, "", 0, 1, \@fleet);
};

1;
