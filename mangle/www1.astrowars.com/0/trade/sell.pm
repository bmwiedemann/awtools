s/(What)( you want to)/$1 do$2/;
s{<input type="text" id="([^/>]+/></td>\s*<td>)(\d+)</td>}
 {<input type="number" min="0" max="$2" id="$1$2</td>}g;
1;
