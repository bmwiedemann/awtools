
# pre-select interstellar trade (PP to A$)
   s/input type="radio" name="produktion" value="trade"/$& checked/;

# disable crappy choices
   s/<input type="radio" name="produktion" value="(destroyer|cruiser|battleship|starbase)">//g;

1;
