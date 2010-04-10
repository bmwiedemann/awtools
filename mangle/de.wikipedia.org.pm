#use lib "/home/aw/inc";
use typocheck;
use Encode;
#use utf8;
#use encoding "utf8";

#binmode STDOUT, ":utf8";
#$_.="$ENV{REQUEST_URI} ; $ENV{QUERY_STRING}";
$_=decode_utf8($_);
if($ENV{REQUEST_URI}=~m{wikipedia.org/w/index.php.*action=(edit|submit)}) {
	if(!m{<li id="pt-preferences"><a href="/wiki/Spezial:Einstellungen" title="Eigene Einstellungen">Einstellungen}) {
		$_="denied. please log in first.";
	}
   if(m{<textarea name="wpTextbox1" id="wpTextbox1" cols="80" rows="25" tabindex="1" accesskey="," style="width: 100%">([^<>]+)^</textarea>}m) {
		my $text=$1;
		typocheck::init();
		my $corr=join("\n", typocheck::checktext($text));
		typocheck::finish();
		s{</head>}{<style type="text/css">.goodpart {color:green; font-weight: bold;} .badpart {color:red; font-weight: bold;}</style>$&};
		s{<div id='toolbar'>}{$corr$&};
	}
}

if($ENV{REQUEST_URI}=~m{wikipedia.org/(wiki/Spezial:Search)|(w/index.php\?title=Spezial%3ASuche)}) {
	s{<a href="/wiki/([^"]+)"}{<a href="/w/index.php?title=$1&action=edit">Edit</a> $&}g;
}
#$_.="testOK";

1;
