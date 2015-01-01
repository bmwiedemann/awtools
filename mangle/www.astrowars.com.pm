s{(Free Online Multiplayer Game)(</title>)}{$1 - brownie version$2};
$::options{url}=~m{http://[^/]*/(.*)} && s{</head>}{<link rel="canonical" href="http://www.astrowars.com/$1" >\n$&};

1;
