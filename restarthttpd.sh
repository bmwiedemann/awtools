#!/bin/sh
LANG=C
kill `cat /tmp/apache-brownie.pid` 
while killall -0 apache2 ; do sleep 1 ; done
#ln -s /host/log/brownie.log /tmp/
#ln -s /host/log/aw-access_log log/
mkdir -p /tmp/aw
a=/usr/sbin/httpd2-prefork
a=/usr/sbin/apache2
$a -d `pwd` -f httpd-brownie.conf

