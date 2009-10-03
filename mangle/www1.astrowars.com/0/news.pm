use awinput;

# link mail from
s%(>You have new mail from )([^<]+)(.<br><a href)%"$1<a href=/0/Player/Profile.php/?id=".playername2id($2).">$2</a>$3"%ge;
s%>([^<>]+)( accepted your TA offer.</td></tr>)%"><a href=/0/Player/Profile.php/?id=".playername2id($1).">$1</a>$2"%ge;

# add links to systems
my $maplink='<a href="/0/Map/Detail.php/?nr=';
s%((?:We just colonized|We conquered|We lost|The people are not willing to take over) )([^.!]+)( \d+)[.!]%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%(The people are not willing to colonize )([^.!]+)( \d+) and follow your leadership.%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%((?:The population decreased by \d+ at) )([^.!]+)( \d+)[.]%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%(Congratulations! (?:Your attacking fleet was|We were) victorious at )([^.]+)( \d+)\.%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%(Your (?:attack|defend)ing fleet was defeated by <a href=[^<]*</a> at )([^.]+)( \d+)(\. You killed about \d+\%\.)%$1.$maplink.systemname2id($2).qq'">$2</a>$3$4'%ge;

if(0 && s%Premium\s+Tools\s*</a></td>%$&<td>|</td><td><a href="/0/Alliance/Incomings.php">AllInc</a></td>%) {
   s%</body%<span class="bmwnotice">note: AllInc link does only work after viewing alliance screen once (per login)</span>$&%;
}

# add CSS classes to tables
my $n=1;
s%(?:<table border="0" CELLSPACING="1" CELLPADDING="1" width="600")|(?:<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#303030' width="600")%$&.' class="sub_inner" id="news'.($n++).'"'%ge;

# fix broken HTML
s%</td><td><a href="Help.php">Help%$&</a>%;
# add counter - 82x34
s%</body>%<a href="http://6bone.informatik.uni-leipzig.de/ipv6/stats/stats.php3"><img src="http://6bone.informatik.uni-leipzig.de/ipv6/stats/log.php3?URL=www.zq1.de&ImageId=5" border="0" width="82" height="34"></a>$&%;

require "mangle/special/color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();

1;
