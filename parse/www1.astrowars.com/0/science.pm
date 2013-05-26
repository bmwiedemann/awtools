use strict;
use awparser;
use awstandard;

foreach my $line (m{<tr(.+?)</tr>}gs) {

	if($line=~m{^ class="sciencePointer">.*Glossary/index\.php\?id=\d+">([^<]+)</a>}s) {
		$d->{currentscience}=$1;
	}
	if($line=~m{^ class="scienceET">\s*<td.*>Estimated date.*: ($awstandard::awdatere)}){
		$d->{etc}=parseawdate($1)-$d->{timezone}; # ETC is local time, but we store UTC
	}
   elsif(my @a=($line=~m{id=\d+">([^>]+)</a></td>\s*<td>(\d+)</td>\s*<td class="progressBar2"><div class="progressBar" style="width: (\d+)%">\d+%</div></td>\s*<td>(?:<input type="text" value=")?(\d+)(?:" size="8" name="." class="inputRead" />)?</td>\s*<td>(?:<input type="text" value=")?([0-9:]+(?: days)?)}s)) {
      my $sl=$a[1]+($a[2]/100);
		$d->{lc($a[0])}={level=>$sl, remain=>int($a[3]), "t"=>$a[4]};
	}
	elsif($line=~m{^>\s*<th}) {
		foreach my $what ("Culture", "Science") {
			if(my @a=($line=~m!$what</a> ([+-]\d+)% <a href="\.\./Glossary/index\.php\?id=23">\(\+([0-9.]+)/h\)</a>!)) {
				$a[0]||=0;
				foreach my $a (@a) {$a+=0}
				$d->{lc($what)."plus"}={hourly=>$a[1], bonus=>$a[0]};
			}
		}
	}
	else {
		$d->{debug}=$line;
	}
}


1;
