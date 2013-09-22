package mangle::special::use_css;
use strict;
#use awstandard;

sub mangle() {
	s/<div id="menu" /$&class="top_navi" /;
	return 0;
my $g=$mangle::dispatch::g;# || ($::options{name} eq "snappyduck");
if($::options{url}=~/www1\.astrowars\.com\/0/) {
   if($g) {
   }
   s%(<body) leftmargin=0 topmargin=0 bgcolor="#000000">%$1>%;
   s%<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#404040' width="600">\n<tr height=15 align="center"><td width="140" bgcolor="#202060">%<table class="top_navi">\n<tr class="t_navi_links" id="topnav"><td class="t_navi_title">%;
   s%<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#000000' width="600">%<table class="main_outer">%;
   s%<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="1" bgcolor='#000000' width="600">%<table class="main_inner" cellspacing="1">%;
   s%<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" bgcolor='#404040' width="600">(\s+<tr) height=15%<table class="bottom_navi">$1 class="t_navi_links" id="bottomnav"%;
   
   my $c=qr/([34]0)\1\1/;
   s%<tr align=center bgcolor="?#$c"? onMouseOver=this.style.backgroundColor="#206060"   onMouseOut=this.style.backgroundColor="#$c"%<tr class="mouseout$1" onMouseOver="this.className='mousein$1'"   onMouseOut="this.className='mouseout$1'"%go;
   s/width=(\d+%)/width="$1"/g;
}
}

1;
