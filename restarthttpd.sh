#!/bin/sh
LANG=C
mkdir -p /tmp/aw
kill `cat /tmp/aw/apache-brownie.pid`
n=10
while test $n -gt 0 && killall -0 apache2 ; do sleep 1 ; n=$(expr $n - 1) ; done
sleep 5; killall -9 apache2
kill `pidof apache2`
n=15
while test $n -gt 0 && killall -0 apache2 ; do sleep 1 ; n=$(expr $n - 1) ; done
#ln -s /host/log/brownie.log /tmp/
#ln -s /host/log/aw-access_log log/
mkdir -p /tmp/aw
chown bernhard. /tmp/aw
a=/usr/sbin/httpd2-prefork
a=/usr/sbin/apache2
$a -d `pwd` -f httpd-brownie.conf

