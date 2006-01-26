# clear input field
my $script='<script language="javascript" type="text/javascript">document.form.points.focus();</script>';

my $points="";
if($::options{url}=~/points=(\d+)/) {$points=$1}
if($::options{url}=~/produktion=(\w+)/) {
   my $prod=$1;
   s/name="produktion" value="$prod"/$& checked/;
}
s%<form action="/0/Planets/submit.php"%$& name="form"%;
s/(<input type="text" name="points" size="3" class=text value=")(\d+)("\s*> \/ \d+)/$1$points$3 <a href="#all" onClick="document.form.points.value=$2;">all<\/a> $script/;

1;
