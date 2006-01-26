#s%^<b>Alliance</b></td>%$& <td>$::bmwlink/alliance?alliance=$ENV{REMOTE_USER}">AWtools</a></td><td>|</td>%m;
my $alli=$ENV{REMOTE_USER};
s%<td><a href=/0/Alliance/>Overview</a></td>%<td>$::bmwlink/alliance?alliance=$alli">AWtools($alli)</a></td><td>|</td> $&%;

1;
