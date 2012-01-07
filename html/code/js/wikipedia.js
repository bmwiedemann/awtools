function jumptotext(needle) {
	var area=document.getElementById("wpTextbox1");
	var pos=area.value.search(needle);
	area.focus();
	area.setSelectionRange(pos,pos+needle.length);
}

