var starttime;
var startd = new Date();
var reftime = new Array();

function C(k)
{
	var now = new Date();
	var diff=(now.getTime()/1000) - starttime - startdiff;
	now.setTime((reftime[k]+diff)*1000);
	document.forms[k].z.value=now.toLocaleString();
	//document.forms[k].z.value=now.toGMTString();
}

