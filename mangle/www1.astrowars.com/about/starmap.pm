sub escape($)
{ my($x)=@_;
	$x=~s/ /+/;
	return $x;
}

s%<b>([^<]+)(</b>\n<small>)%"<b>$::bmwlink/system-info?name=".escape($1).qq'">$1</a>$2'%e;

1;
