#s%^<b>Alliance</b></td>%$& <td>$::bmwlink/alliance?alliance=$ENV{REMOTE_USER}">AWtools</a></td><td>|</td>%m;
my $alli=$ENV{REMOTE_USER};
s%<td><a href=/0/Alliance/>Overview</a></td>%<td>$::bmwlink/alliance?alliance=$alli">AWtools($alli)</a></td><td>|</td> $&%;
s%<table border=0 cellpadding=1 cellspacing=1 width=600%$& class="main_inner" id="alliance"%i; # add CSS info to allow customization


# add direct links for details pages
if($::options{url}=~m%/0/Alliance/$%) {
   my $n=0;
   s%(<td>)(\d+)(</td><td><a href=http://www.astrowars.com/forums/privmsg.php)%$1.'<a href="Detail.php/?id='.$n++.'">'.$2."</a>".$3%ge;
#   s%</body>%<span class="bmwnotice">note: new direct links behind points of players.</span><br>$&%;
# provide classic all-incos to premiums:
s{>Premium incomings list</a></td>\s*</tr>}{$&<tr><td colspan="2" class="incoming"><a href="Incomings.php">All-Incomings</a></td></tr>}

}

s%(<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000') width="600"%$1 class="main_inner" id="allianceoverview"%;
s{width="260">}{width="100%" class="allianceinfo">};
s{width="340">}{width="100%" class="alliancemembers">};
#s{ width="600">}{>};

1;
