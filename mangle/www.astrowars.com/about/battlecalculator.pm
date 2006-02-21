s/(form action="" method=")post/$1get/;
s%</td></tr></table>%$&<a style="color:green" href="$::options{url}">Link to this page</a>%;

1;
