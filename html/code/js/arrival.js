var browniedomain = "www1.astrowars.com";
var starttime;
var startd = new Date();

var energy=1;			// example
var racebonus=2;	// example (speed+2)
var tz=0;

// AW global constant values
var const1=85*600;		// launch time cost (sec)
var const2=34*3600;		// 1AU fly cost (sec)
var const3=0.1;		// planet fly cost is 10% of const2
var const4=91/100;	// energy gain

var disttable=new Array;

function travel_time(distsqr, planets, own) {
	var time = (const1 + Math.sqrt(Math.sqrt(distsqr)+planets*const3)*const2)
	   * Math.pow(const4,energy);
	var ttmalus=3600*(5-racebonus);
	if(distsqr==0) ttmalus/=4;
	if(own) return ((time+ttmalus)/2);
	return (time+ttmalus);
}

var noupdate=0;



// This sprintf code is in the public domain. Feel free to link back to http://jan.moesen.nu/
function sprintf()
{
	if (!arguments || arguments.length < 1 || !RegExp)
	{
		return;
	}
	var str = arguments[0];
	var re = /([^%]*)%('.|0|\x20)?(-)?(\d+)?(\.\d+)?(%|b|c|d|u|f|o|s|x|X)(.*)/;
	var a = b = [], numSubstitutions = 0, numMatches = 0;
	while (a = re.exec(str))
	{
		var leftpart = a[1], pPad = a[2], pJustify = a[3], pMinLength = a[4];
		var pPrecision = a[5], pType = a[6], rightPart = a[7];
		
		//alert(a + '\n' + [a[0], leftpart, pPad, pJustify, pMinLength, pPrecision);

		numMatches++;
		if (pType == '%')
		{
			subst = '%';
		}
		else
		{
			numSubstitutions++;
			if (numSubstitutions >= arguments.length)
			{
				alert('Error! Not enough function arguments (' + (arguments.length - 1) + ', excluding the string)\nfor the number of substitution parameters in string (' + numSubstitutions + ' so far).');
			}
			var param = arguments[numSubstitutions];
			var pad = '';
					 if (pPad && pPad.substr(0,1) == "'") pad = leftpart.substr(1,1);
			  else if (pPad) pad = pPad;
			var justifyRight = true;
					 if (pJustify && pJustify === "-") justifyRight = false;
			var minLength = -1;
					 if (pMinLength) minLength = parseInt(pMinLength);
			var precision = -1;
					 if (pPrecision && pType == 'f') precision = parseInt(pPrecision.substring(1));
			var subst = param;
					 if (pType == 'b') subst = parseInt(param).toString(2);
			  else if (pType == 'c') subst = String.fromCharCode(parseInt(param));
			  else if (pType == 'd') subst = parseInt(param) ? parseInt(param) : 0;
			  else if (pType == 'u') subst = Math.abs(param);
			  else if (pType == 'f') subst = (precision > -1) ? Math.round(parseFloat(param) * Math.pow(10, precision)) / Math.pow(10, precision): parseFloat(param);
			  else if (pType == 'o') subst = parseInt(param).toString(8);
			  else if (pType == 's') subst = param;
			  else if (pType == 'x') subst = ('' + parseInt(param).toString(16)).toLowerCase();
			  else if (pType == 'X') subst = ('' + parseInt(param).toString(16)).toUpperCase();
			while(((""+subst).length)<minLength) {
				subst=pad+subst;
			}
		}
		str = leftpart + subst + rightPart;
	}
	return str;
}



function datetoISOstring(date) {
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d", date.getFullYear(), date.getMonth()+1, date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds());
}

function update() {
	if(noupdate) return;
	if(document.forms[0].energy) {energy=document.forms[0].energy.value}
	var dstsid=document.forms[0].destination.value;
	if(document.forms[0].destination2 && document.forms[0].destination2.value!="") 
		dstsid=document.forms[0].destination2.value;
	var dist=disttable[dstsid];
	var outt="-";
	var outa="-";
	var dstpid=document.forms[0].planet.value;
	if(dstsid && dist && dist[dstpid]>=0) {
		var srcpid=document.forms[0].id.value;
		var tt=travel_time(dist[0], Math.abs(dstpid-srcpid), dist[dstpid]);
		var min=Math.floor((tt/60)%60);
		var sec=Math.floor(tt%60);
		var startd = new Date();
		var endd = new Date(startd.getTime()+tt*1000);
		outt=Math.floor(tt/3600)+":"+(min>9?min:"0"+min)+":"+(sec>9?sec:"0"+sec);
//		outa=endd.toGMTString();
//		outa=endd.toLocaleString();
		outa=datetoISOstring(endd)+" UTC+"+tz+" = "+endd.toLocaleString();
	}
	document.forms[1].travel.value=outt;
	document.forms[1].arrival.value=outa;
}

function asyncfetchdist(sid1)
{
	if(disttable[sid1]) return;
	// use window.location.host instead of browniedomain
	Ab("http://"+window.location.host+"/brownie/systemowners?sid="+sid1, function(c,s) {
         if(c == 'NOTFOUND') return;
         var a=c.split(" ");
         var dx=a[12]-sx;
         var dy=a[13]-sy;
			disttable[sid1]=new Array;
         disttable[sid1][0]=dx*dx + dy*dy;
         for(i=0; i<12; i++) {
            var own=(a[i]==-1)?-1:(a[i]==aid?1:0);
            disttable[sid1][i+1]=own;
         }
		}, 0);
}

//window.setInterval("update()", 100);

