#$ENV{HTTP_COOKIE}=${$::options{headers}}{Cookie};

if($ENV{HTTP_COOKIE}=~m/c_user=greenbird/) {
	$_="";
}
1;
