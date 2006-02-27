use awinput;

# link mail from
s%(>You have new mail from )([^<]+)(.<br><a href)%"$1<a href=/0/Player/Profile.php/?id=".playername2id($2).">$2</a>$3"%ge;

# add links to systems
my $maplink='<a href="/0/Map/Detail.php/?nr=';
s%((?:We just colonized|We conquered|We lost|The people are not willing to take over) )([^.!]+)( \d+)[.!]%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%((?:The population decreased by \d+ at) )([^.!]+)( \d+)[.]%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%(Congratulations! (?:Your attacking fleet was|We were) victorious at )([^.]+)( \d+)\.%$1.$maplink.systemname2id($2).qq'">$2</a>$3.'%ge;
s%(Your (?:attack|defend)ing fleet was defeated by <a href=[^<]*</a> at )([^.]+)( \d+)(\. You killed about \d+\%\.)%$1.$maplink.systemname2id($2).qq'">$2</a>$3$4'%ge;

if(0 && s%Premium\s+Tools\s*</a></td>%$&<td>|</td><td><a href="/0/Alliance/Incomings.php">AllInc</a></td>%) {
   s%</body%<span class="bmwnotice">note: AllInc link does only work after viewing alliance screen once (per login)</span>$&%;
}

require "mangle/special/color_incomings.pm"; mangle::special_color_incomings::mangle_incoming();

1;
