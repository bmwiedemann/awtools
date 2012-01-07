// from http://maps.google.com/mapfiles/maps2.73.js


// return HTTP requester obj
function Lo(){
	try{
		if(typeof ActiveXObject!="undefined"){
			return new ActiveXObject("Microsoft.XMLHTTP")
		}else if(window.XMLHttpRequest){return new XMLHttpRequest}
	}catch(a){}
	return null
}

function Tf(){}

// input string:URL
// input func:readyfunc(data,status)
// input bool:post
// input string:form-enc-type
function Ab(a,b,c,d){
	var e=Lo();
	if(!e)return false;
	if(b){
		e.onreadystatechange=function(){
			if(e.readyState==4){
				b(e.responseText,e.status);
				e.onreadystatechange=Tf
			}
		}
	}
	
	if(c){
		e.open("POST", a,true);
		var f=d;
		if(!f){
			f="application/x-www-form-urlencoded"
		}
		e.setRequestHeader("Content-Type",f);e.send(c)
	}
	else{
		e.open("GET",a,true);
		e.send(null)
	}
	return true
}

