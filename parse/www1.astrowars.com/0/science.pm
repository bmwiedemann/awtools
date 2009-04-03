use strict;
use awparser;
use awstandard;

foreach my $line (m{<tr align=center bgcolor=(.+?)</tr>}gs) {

	if($line=~m{^'#206060'><td><a href=/0/Glossary[^>]+>([^<]+)</a>}) {
		$d->{currentscience}=$1;
	}
	if(my @a=($line=~m{([^>]+)</a> </td><td>(\d+)</td><td><img src="/images/dot.gif" height="10" width="(\d+)"><img src="/images/leer.gif" height="10" width="(\d+)"></td><td>(?:<form><input type="text" value=")?(\d+)(?:" size="8" name="r" class=text style="text-align:center;">)?</td><td>(?:<INPUT type="text" value=")?([0-9:]+(?: days)?)})) {
      my $sl=$a[1]+($a[2]/260);
		$d->{lc($a[0])}={level=>$sl, remain=>int($a[4]), "t"=>$a[5]};
	}
	elsif($line=~m{^"#202060"}) {
		foreach my $what ("Culture", "Science") {
			if(my @a=($line=~m!$what.*href="/0/Glossary//\?id=23">\(\+(\d+) per hour\)</a>((?:\s<b>[+-]\d+%)|)!)) {
				$a[1]=~s/.*([+-]\d+).*/$1/;
				$a[1]||=0;
				foreach my $a (@a) {$a+=0}
				$d->{lc($what)}={hourly=>$a[0], bonus=>$a[1]};
			}
		}
	}
	else {
		$d->{debug}=$line;
	}
}


1;
