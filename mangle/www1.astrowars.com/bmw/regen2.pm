
s{http://stats.t-online.de}{/bmw/regen/stats}g;
s{http://data.wetter.info}{/bmw/regen/data}g;
s{http://www.wetter.info}{/bmw/regen}g;
s{<div class="Tsib">.*}{}s;
s{<div id="Thead2".*?</div>}{}s;
s{width:1250px;}{width:900px;}g;
s{.*Anzeige.*}{};
s{[^\n]*\n[^\n]*IM.GlobalAdTag.register.*?</script>}{}gs;
s{.*poweredby.*\n.*}{};
s{<img }{$&alt="" }g;
s{</div>  </div><br class="Tcontbend" />\n</div>}{};

1;
