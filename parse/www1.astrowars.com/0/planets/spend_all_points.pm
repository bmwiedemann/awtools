use strict;
use awparser;

for my $v (qw(cruiser battleship trade)) {
   $d->{$v}=tobool(m/value="$v"/);
}

2;
