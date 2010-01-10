package awmapcgi;
use strict;
use awstandard;
use awinput;
use CGI ":standard";


our %maptypestring=("0,6,1,2"=>"alli+relation", "0,1,2"=>"relation", "1"=>"plans", "0,3,4"=>"fleets", 5=>"population");

sub awmapcoordinput() {
	my @pos=(0,0);
	my @s=(29,25);
	if($ENV{REMOTE_USER} eq "af") { @pos=(-35,-35); }
#	elsif($ENV{REMOTE_USER} eq "sw") { @pos=(-57,47); $s[1]=37; }
#	elsif($ENV{REMOTE_USER} eq "tgd") { @pos=(69,-15); $s[1]+=10; }
#	elsif($ENV{REMOTE_USER} eq "xr") { @pos=(60,-54) }
#	elsif($ENV{REMOTE_USER} eq "kk") { @pos=(-26,-13) }
#	elsif($ENV{REMOTE_USER} eq "wink") { @pos=(12,42) }
#	elsif($ENV{REMOTE_USER} eq "love") { @pos=(-75,48) }
        my $awuid=getuseridcookie();
        if($awuid>2) {
		my $home=playerid2home($awuid);
		@pos=systemid2coord($home);
	}
	my $s=5;
   my @bio;
   for my $i (3..13) {push(@bio,2*$i)}
   my $ret=textfield(-name=>'xs', -value=>$pos[0], -size=>$s, -class=>'text'). " x position (center)". br.AWfocus("form.xs").
		textfield(-name=>'ys', -value=>$pos[1], -size=>$s, -class=>'text'). " y position (center)". p.
      div({class=>"grouping"},
		textfield(-name=>'xe', -value=>$s[0], -size=>$s, -class=>'text'). " width". br.
		textfield(-name=>'ye', -value=>$s[1], -size=>$s, -class=>'text'). " height". br.
      " or ".br.popup_menu(-values=>\@bio, -onChange=>"document.form.xe.value=document.form.ye.value=Math.ceil(document.form.elements[4].value)+1")." Bio").br;
   
   return $ret;
}

1;
