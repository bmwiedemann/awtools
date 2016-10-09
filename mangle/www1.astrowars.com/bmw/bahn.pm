
m{<h2>Hinfahrt.*?</table>}s and 
$_= qq{$&};

s{/bin/query}{/bmw/bahn$&}g;
s{<script type="text/javascript".*?</script>}{}gs;
s{<img src.*}{}g;
s{.*Preisauskunft nicht m&#246;glich</a>}{}g;
s{Preis f&#252;r alle Reisenden inkl. Erm&#228;&#223;igungskarten\*}{};
s{R&#252;ckfahrt hinzuf&#252;gen}{}g;
s{Details einblenden}{}g;
s{</div>\n</form>}{};
s{<tr>\n<th.*?</th>\n</tr>}{}s;

$_=qq{<html><head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
</head><body>
<style >
      .ontime { color: green; }
      .delay { color: #CC0000; }
</style>$_};

1;
