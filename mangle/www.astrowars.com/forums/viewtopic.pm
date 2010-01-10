
sub substlink($)
{
   my $name=shift;
   my $pid=playername2id($name)||$name;
   return qq(<a href="profile.php?mode=viewprofile&amp;u=$pid">).$name."</a>";
   return $name;
}

s{(<td width="150" align="left" valign="top" class="row\d"><span class="name"><a name="\d+"></a><b>)([^<>]+)(</b></span><br />)}{$1.substlink($2).$3}ge;

2;
