s/(<input type="text" name="q\d+" size="5" class=text value=")(\d+)(">)/${1}1$3 \/ $2 /g;

s/(What)( you want to)/$1 do$2/;
1;