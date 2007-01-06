package mangle::special;

sub mangle() {
   
   # modify title to work better with tabs
   s/^\s*(<html><head><title>) Astro Wars /$1/;
   
   if($ENV{REMOTE_USER}) {
   # remove text ads
      s/<table><tr><td><table bgcolor="#\d+" style="cursor: pointer;".*//;
   # disable other ads
      s/(?:pagead2\.googlesyndication\.com)|(?:games\.advertbox\.com)|(?:oz\.valueclick\.com)|(?:optimize\.doubleclick\.net)/aw.lsmod.de/g;
   }
   # fix color specification
   s%bgcolor="([0-9a-fA-F]{6})"%bgcolor="#$1"%g;
   s%bgcolor=#([0-9a-fA-F]{6})%bgcolor="#$1"%g;
   # add icon
   s%</head>%<link type="image/vnd.microsoft.icon" rel="icon" href="http://aw.lsmod.de/awfavicon.ico">\n<link rel="shortcut icon" href="http://aw.lsmod.de/awfavicon.ico">\n</head>%;
}

1;
