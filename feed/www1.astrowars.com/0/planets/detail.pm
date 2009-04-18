use awstandard;
use awbuilding;

my $d=getparsed(\%::options);

#awdiag("planets feeding ".length($_));
#open(F, ">/tmp/)
if($d->{sieging} && m!Transport</a></td><td>(\d+).* Colony Ship</a></td><td>(\d+).* Destroyer</a></td><td>(\d+).* Cruiser</a></td><td>(\d+).* Battleship</a></td><td>(\d+).*<a href="?/0/Player/Profile.php/\?id=(\d+)"?>Hostile forces in the orbit of ([^\!]*) (\d+)\!!s) {
	# TODO optimize my @fleet=($d->{colonyship}->{num},...,$d->{battleship}->{num}||0);
   my @fleet=($1,$2,$3,$4,$5);
   my ($owner, $sid, $pid) = ($6, systemname2id($7), $8);
#   awdiag("@fleet $6 sieges $sid $pid");
   dbplanetaddinit(undef, 8);
   dbfleetadd($sid, $pid, $owner, "", 0, 1, \@fleet);
};

my %h=(pp=>$d->{productionpoints}->{num}, "pop"=>$d->{population}->{num},
	hf=>$d->{hydroponicfarm}->{num}, rf=>$d->{roboticfactory}->{num}, 
	gc=>$d->{galacticcybernet}->{num}, rl=>$d->{researchlab}->{num}, 
	sb=>$d->{starbase}->{num} );

update_building($d->{sid},$d->{pid},1,\%h);

1;
