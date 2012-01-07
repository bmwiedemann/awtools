function update_field(to_field, from_field, n3, factor)
{
	var n = document.form.elements[from_field].value;
	if(n>0) {
		document.form.elements[to_field].value=n*factor;
		document.form.produktion[n3].checked=true;
//	alert("update "+to_field+" "+n);
	}
}
