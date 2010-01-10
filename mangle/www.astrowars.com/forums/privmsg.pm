sub substlink($)
{
	my $name=shift;
   my $pid=playername2id($name)||$name;
	return qq(<a href="profile.php?mode=viewprofile&amp;u=$pid">).$name."</a>";
	return $name;
}

s{(<td class="row2"><span class="genmed">(?:From|To):</span></td>\s+<td width="100%" class="row2" colspan="2"><span class="genmed">)([^<>]+)(</span></td>)}{$1.substlink($2).$3}ge;

2;
