use strict;

if($::options{nclick}<300) {
	2; # all OK - go on processing normally
} else {
	$::options{mime}="text/html";
	$_=qq(<html><body>This is a message from brownie: 
You have reached $::options{nclick} clicks and to prevent you from being blocked for flooding, brownie is not passing further requests to the game.<br>
What you can do:
<ol>
<li>try to log in again
<li>disable any javascript
<li>close all browser windows
</ol>
<hr>
Please <a href="http://home.rebelstudentalliance.co.uk/forum/index.php/board,17.0.html">give feedback about this feature</a>
</body></html>
);
	1;
}
