# activate arrival calc checkbox
s/<input type="checkbox" name="calc" value="1"/$& checked/;


# convert radio list into drop-down list
my @list=();
my $page;
for($page=$_; $page=~s%<tr align=center><td bgcolor='#404040'><a href=/0/Map//\?hl=\d+>([^<]*)</a></td><td><input type="radio" name="destination" value="(\d+)"\s*(checked)?></td></tr>%% ; ) {
   push(@list,[$1,$2,$3]);
}

my $extra=qq'<select name="destination"><option value=""></option>';
foreach my $e (@list) {
   my($name,$id,$checked)=@$e;
   my $sel=$checked||"";
   $sel=~s/checked/ selected/;
   $extra.=qq%<option$sel value="$id">$name</option>%;
}
$extra.="</select>";

$page=~s%<td colspan="3">Destination</td></tr>%$&<tr align=center><td bgcolor='#404040'>$extra</td></tr>%;

$_=$page;
#$_.=$extra;

1;
