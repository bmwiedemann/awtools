# correct signs with points to reduce people's confusion with in-game races

my %neg=(
      "+"=>"-",
      "-"=>"+");
s!<td>([+-])([1-7])</td>!<td>$neg{$1}$2</td>!g;

# colorize bad and non-recommended races
my $badlimit=-25;
my $nrlimit=-13;

#http://www1.astrowars.com/register/start.php?id=$pid&name=$name&pw=xxx&raceid=0&growth=0&science=0&culture=0&produktion=0&speed=0&attack=0&defense=0};
#s{language="JavaScript"><!--}{$&\nfunction updateracelink(){
s{function resetform()}{\nfunction updateracelink(){
	var pid=document.getElementsByName("id2")[0].value;
	var pname=document.getElementsByName("name2")[0].value;
	var pw=document.getElementsByName("pw2")[0].value;
	var raceid=0;
	var auswahl=document.getElementsByName("auswahl[]");
	for(var i = 0; i <= 1; i++)
		if(auswahl[i].checked) raceid+=(1*auswahl[i].value);
	document.getElementById("racelink").value="http://www1.astrowars.com/register/start.php?id="+pid+"&name="+pname+"&pw="+pw+"&raceid="+raceid+"&growth="+(-growth)+"&science="+(-science)+"&culture="+(-culture)+"&produktion="+(-produktion)+"&speed="+(-speed)+"&attack="+(-attack)+"&defense="+(-defense);
}\n$&};
s{function update\(element\) \{}{$&\n\tupdateracelink();};
my $racelink=qq{<br>Race link: <br><input type="text" value="" name="racelink" id="racelink" class="text" size="102" onfocus="updateracelink()">};

s!(h1>Create your own race)(\!</h1>)!$1$2<i>modified by <span style="color:green">greenbird</span> to help you choosing good races... <span class="badcolor">red=bad (below $badlimit\%)</span>, <span class="notrecommended">yellow=not recommended (below $nrlimit%)</span></i> <br>oh and <span style="color:red">plus/minus changed by brownie to reduce people's confusion with in-game races</span>$racelink!;


s%type="text/css"><!--%$&\n.bad { color : #f66;}\n.nr { color : #fd0;}%;
s!(colspan="2")>(-\d{1,2})(%</td>)!$2>$badlimit?"$1>$2$3":"$1 class=\"badcolor\">$2$3"!ge;
s!(colspan="2")>(-\d{1,2})(%</td>)!$2>$nrlimit?"$1>$2$3":"$1 class=\"notrecommended\">$2$3"!ge;

1;
