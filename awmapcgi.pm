use strict;
require "input.pm";

sub awmapcoordinput() {
	my @pos=(0,0);
	my @s=(29,25);
	if($ENV{REMOTE_USER} eq "af") { @pos=(-57,47); $s[1]=37; }
	elsif($ENV{REMOTE_USER} eq "sw") { @pos=(-57,47); $s[1]=37; }
	elsif($ENV{REMOTE_USER} eq "tgd") { @pos=(69,-15); $s[1]+=10; }
	elsif($ENV{REMOTE_USER} eq "xr") { @pos=(60,-54) }
	elsif($ENV{REMOTE_USER} eq "la") { @pos=(26,30) }
	elsif($ENV{REMOTE_USER} eq "blub") { @pos=(57,39) }
	elsif($ENV{REMOTE_USER} eq "love") { @pos=(-75,48) }
        my $awuid=playername2id(cookie('user'));
        if($awuid>2) {
		my $home=playerid2home($awuid);
		@pos=systemid2coord($home);
	}
	my $s=5;
		textfield(-name=>'xs', -value=>$pos[0], -size=>$s, -class=>'text'). " x position (center)". br.AWfocus("form.xs").
		textfield(-name=>'ys', -value=>$pos[1], -size=>$s, -class=>'text'). " y position (center)". p.
		textfield(-name=>'xe', -value=>$s[0], -size=>$s, -class=>'text'). " width". br.
		textfield(-name=>'ye', -value=>$s[1], -size=>$s, -class=>'text'). " height". br;
}

1;
