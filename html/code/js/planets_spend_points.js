function update_field(to_field, from_field, n3, factor)
{
	var f = document.getElementById("spendPP")
	var n = f.elements[from_field].value;
	if(n>0) {
		f.points.value=n*factor;
		f.produktion[n3].checked=true;
//	alert("update "+to_field+" "+n);
	}
}
