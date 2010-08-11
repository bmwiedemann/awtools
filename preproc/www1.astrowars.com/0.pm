use strict;

#if($::options{name} ne "greenbird" || $::options{nclick}<300) {
if($::options{nclick}<300) {
	2; # all OK - go on processing normally
} else {
	$::options{mime}="text/html";
	$_=qq(<html><head>
 <title>brownie had too many clicks</title>
<link rel="stylesheet" type="text/css" href="http://aw.lsmod.de/code/css/main.css">
<link type="image/vnd.microsoft.icon" rel="icon" href="http://aw.lsmod.de/awfavicon.ico">
<link rel="shortcut icon" href="http://aw.lsmod.de/awfavicon.ico">
</head>
<body><h1>brownie had too many clicks</h1>
This is a message from brownie: 
You have reached $::options{nclick} clicks and to prevent you from being blocked for flooding, brownie is not passing further requests to the game.<br>
What you can do:
<ol>
<li>try to log in again
<li>disable any javascript
<li>close all browser windows
</ol>
<hr>
Please <a href="http://forum.rebelstudentalliance.co.uk/index.php/board,17.0.html" class="awtools">give feedback about this feature</a>
</body></html>
);
	1;
}
