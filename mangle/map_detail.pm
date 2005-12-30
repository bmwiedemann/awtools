$::options{url}=~/nr=(\d+)/;
my $id=$1;
s%(Planets at)%$1 $::bmwlink/system-info?id=$id">id=$id</a>%;

1;
