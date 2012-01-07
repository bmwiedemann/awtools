function FindProxyForURL(url, host)
{
//	  if ( dnsDomainIs(host, ".astrowars.com") || dnsDomainIs(host, ".rebelstudentalliance.co.uk"))
	  if ( dnsDomainIs(host, ".astrowars.com"))
			return "PROXY awproxy.zq1.de:81;PROXY aw2.zq1.de:11081;DIRECT";
	  else
			return "DIRECT";
}

