print "profile feed\n";

m/<html><head><title>(\S*)/;
my $name=$1;
print a({-href=>"relations?name=$name"},$name).br."\n";

if(m!>Points: (\d+)</td>!) {
   my $points=$1;
   use DB_File;
   my %pointsdb;
   tie(%pointsdb, "DB_File", "/home/bernhard/db/points.dbm") or print "\nerror accessing DB\n";
   
   print "Points: $points\n";
   $pointsdb{$name}=$points;
}

1;
