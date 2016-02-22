use strict;
use parse::dispatch;

$::options{url}=~s{^http://www1\.astrowars\.com/\d/}{http://www1.astrowars.com/0/};
my $data=parse::dispatch::dispatch(\%::options);

#my $r=$::options{req};
#$r->content_type("text/html");
$_='<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US"><head><title>Fleet</title>
<link rel="stylesheet" type="text/css" href="/code/css/awmod.css" />
<link type="image/vnd.microsoft.icon" rel="icon" href="/code/images/awfavicon.ico" />
<link rel="shortcut icon" href="/code/images/awfavicon.ico" />
</head><body>
<center>
<table border="0" cellspacing="1" cellpadding="2" class="main_inner">
<tr bgcolor="#202060" align="center"><td><small>Estimated Arrival</small></td><td><small>Destination</small> </td><td><a class="awglossary" href="/0/Glossary//?id=25"><small>Transport</small></a></td><td><a class="awglossary" href="/0/Glossary//?id=24"><small>Colony Ship</small></a></td><td><a class="awglossary" href="/0/Glossary//?id=17"><small>Destroyer</small></a></td><td><a class="awglossary" href="/0/Glossary//?id=18"><small>Cruiser</small></a></td><td><a class="awglossary" href="/0/Glossary//?id=19"><small>Battleship</small></a></td></tr>
';

sub syshtml($$$)
{
	my($sid,$pid,$sysname)=@_;
	return "<a href=\"/0/Map/Detail.php?nr=$sid&amp;highlight=$pid\"><small>$sysname $pid</small></a>"
}

my $u=$::options{url};
my $tzoffset=$data->{timezone}||0;
my $offset=0;
my $now=time();
foreach my $f (@{$data->{movingfleet}}) {
	my($sid,$pid,$sysname,$eta,$ship)=($f->{sid},$f->{pid},$f->{system},$f->{eta}, $f->{ship});
	$_.= "<tr class=\"trgray4\"><td>".join("</td><td>",
		sprintf("%.2fh",($eta-$tzoffset-$now)/3600)." ".scalar gmtime($eta+$offset), syshtml($sid,$pid,$sysname),@$ship)."</td></tr>\n";
}
$_.=qq'<tr class="trblue226"><td>Limit $data->{movingfleets}/$data->{maxmovingfleets}</td><td><small>Location</small></td><td colspan="5"></td></tr>';
foreach my $f (@{$data->{fleet}}) {
	my $class=($f->{sieging}?"trsiege":"trgray4");
	my($sid,$pid,$sysname,$ship)=($f->{sid},$f->{pid},$f->{system},$f->{ship});
	$_.= "<tr class=\"$class\"><td>".join("</td><td>","", syshtml($sid,$pid,$sysname),@$ship)."</td></tr>\n";
}
#$_.= "OK $u <br>";

$_.= "</table></center></body></html>";

30;
