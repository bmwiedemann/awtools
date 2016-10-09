use strict;
use XML::Simple;
use parse::dispatch;

my $r=$::options{req};

s{<h2 class="title">Städtewetter}{};
s{<!-- Google Tag Manager.*(<h2>Wetter Röthenbach 3-Tage.*?</h2>)}{}s;
s{<div id="printChart">.*(</body>)}
    {<a href="http://www.t-online.de/wetter/niederschlagsradar/64094056" target="regen">Niederschlag</a>
    <!--a href="http://www.wetter.info/niederschlagsradar-regenradar-plus-schnee-hagel-graupel/56526472">wetterinfo</a-->
    <!--a href="/bmw/regen/niederschlagsradar-regenradar-plus-schnee-hagel-graupel/56526472">regen</a-->
    <a href="/bmw/regen2/wetter/niederschlagsradar/64094056" target="regen">regen2</a>
    <a href="https://reiseauskunft.bahn.de/bin/query.exe/dn?start=1&S=Röthenbach-Seespitze&Z=Nürnberg+Hbf" target="bahn" >origArbeit</a>
    <a href="https://aw21.zq1.de/bmw/bahn/bin/query.exe/dn?start=1&S=Röthenbach-Seespitze&Z=Nürnberg+Hbf" target="bahn">zur Arbeit</a>
    <a href="https://aw21.zq1.de/bmw/bahn/bin/query.exe/dn?start=1&Z=Röthenbach-Seespitze&S=Nürnberg+Hbf" target="bahn">Hbf</a>
	
    $1}s;
s{<img class="loading-spinner.*}{};
s{<script.*?</script>}{}sg;
s{<noscript.*?</noscript>}{}sg;

30; # means return our output $_ verbatim
