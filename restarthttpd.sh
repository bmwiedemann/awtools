#!/bin/sh
LANG=C
kill `cat /tmp/apache-brownie.pid` 
ln -s /host/log/brownie.log /tmp/
ln -s /host/log/aw-access_log log/
mkdir -p /tmp/aw
sleep 1
a=/usr/sbin/httpd2-prefork
a=/usr/sbin/apache2
$a -d `pwd` -f httpd-brownie.conf

