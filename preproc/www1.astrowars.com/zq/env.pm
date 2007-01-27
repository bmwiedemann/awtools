use strict;
use warnings;

print "\n--Options--\n";
foreach my $k (keys %::options) {
   print "$k=$::options{$k}\n";
}
print "\n--Headers--\n";
my $h=$::options{headers};
foreach my $k (keys %$h) {
   print "$k = $h->{$k}\n";
}
print "\n--Headers2--\n";
my $re=$::options{request};
my @h=$re->header_field_names();
foreach my $h (@h) {
   print "$h = ",$re->header($h),"\n";
}
print "\n--ENV--\n";
foreach my $h (keys %ENV) {
   print "$h = ",$ENV{$h},"\n";
}
print "\n--OK--\n";

1;
