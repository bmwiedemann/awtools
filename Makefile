htpasswd=/usr/bin/htpasswd
htpasswdfile=.htpasswd
d=`date +%d-%m-%Y`
mydate=`date +%y%m%d`
awserv=www1.astrowars.com
f2=www1.astrowars.com/export/history/all$d.tar.bz2
topn=500
round=gold11
allies=$(shell ./get_allowed_alliances.pl)
tools=index.html alliance{,2} allirelations arrival arrivalmany authaw authawforum awstatistics awtoolstatistics joinalli cdinfo distsqr ecocheck edit-fleet edit-sharing eta fighterlist fleets preferences{,2} tactical{,-large{,-tile},-live{,2,-tile}} relations relations-bulk system-info xml-info testenv planet-info feedupdatemangle feedupdate ranking racelink sim topwars whocanintercept coord fleetbattlecalc holes hoststats battles loginpos antispy2 antispy playerbattles{,3} guessrace imessage tradepartners whocansee permanentranking adminlookup adminuseralli adminviewbrownie uploadcss playeronline playeronline2 passwd plhistory ipban logout
#allies=
#winterwolf arnaken manindamix tabouuu Rasta31 bonyv Rolle
all: TA.candidate
test:
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 ; do ./arrival.pl -p $$i ; done
links:
	ln -f ${tools} cgi-bin/
	ln -f topwars cgi-bin/topallis
	ln -f ${tools} cgi-bin/public
	ln -f topwars cgi-bin/public/topallis
	ln -f html/images/aw/?.gif html/


init:
	$(MAKE) links
	perl -e 'print rand(1000000000000000)."\n"' > systemexportsecret
	./create-mysql-tables.pl
	wget -Oalltrades.csv http://aw.lsmod.de/alltrades.csv

#system-ids.txt:
#	grep 303030 ~/public_html/aw/id.html | perl -ne 'm%>([^>]*)</td>%;print $1,"\n"' > ~/code/cvs/perl/awcalc/system-ids.txt
updateprices:
	wget -x -o/dev/null http://www1.astrowars.com/0/Trade/prices.txt
	perl importcsv.pl prices
	chmod 660 newdb/*
	mv newdb/prices.mldbm db/
	rm -f newdb/*

updatecsv: dumpdbs
	wget -x -nc -o/dev/null http://${f2}
	tar xjf ${f2}
	-grep -v id trade.csv >> alltrades.csv
	wget -x -o/dev/null http://www1.astrowars.com/0/Trade/prices.txt
	make importcsv
	wget -o/dev/null http://${awserv}/rankings/bestguarded.php -O${awserv}/rankings/bestguarded-$d.html
	wget -o/dev/null http://${awserv}/rankings/strongestfleet.php -O${awserv}/rankings/strongestfleet-$d.html
	-for i in 4 3 2 1 ; do mv html/strongestfleet-{$$i,`expr $$i + 1`}.html ; done
	-perl manglestrongestfleet.pl www1.astrowars.com/rankings/strongestfleet-$d.html www1.astrowars.com/rankings/bestguarded-$d.html
	perl importcsv-mysql.pl
	#(cd html/awcache/ ; find -type f ) | perl -pe 's/^..//' > html/awcache/cache-list.txt
	rm -f html/awcache/www1.astrowars.com/images/galaxymap.png

importcsv:
	umask 2 ; mkdir -p db olddb newdb ; perl importcsv.pl && ( ln -f db/* olddb/ ; mv newdb/* db/ )
	-./checkrenames.pl

#runs once a day
updatedaily:
	#- cd /home/bernhard/code/cvs/perl/awcalc/html/images/sig/auto; make slotd background.png background-large.png ; make
	-perl detectalliancerelation.pl > html/${round}/alliancerelation-${mydate} &&\
	ln -f html/${round}/alliancerelation-${mydate} html/${round}/alliancerelation && \
	(perl alliancerelation2dot.pl html/round/alliancerelation-${mydate} | neato -Tsvg > html/${round}/alliancerelation-${mydate}.svg &&\
	ln -f html/${round}/alliancerelation-${mydate}.svg html/${round}/alliancerelation.svg &&\
	convert -density 70 html/round/alliancerelation.svg html/round/alliancerelation.png )&

banupdate: html/badproxylist.txt banbadproxies.pl
	touch $@
	-perl banbadproxies.pl

#runs 4 times a day
updatexdaily: updateholes updatespy
updatemap: updatemaponly
updatemapsonly: updatemaponly updatemap2only
updatemaponly:
	for a in $(allies) ; do \
	REMOTE_USER=$$a /usr/bin/nice -n +12 perl drawtactical.pl ; done
updatemap2: cleandbs updatemapsonly
updatemap2only:
	#for a in $(allies) ; do \ REMOTE_USER=$$a /usr/bin/nice -n +12 perl tabmap.pl ; \ done
cleanmap2:
	find html/alli/*/l -name \*.png|xargs rm -f
updateholes:
	for a in $(allies) ; do \
		REMOTE_USER=$$a perl holes3.pl > html/alli/$$a/holes.csv ; \
		REMOTE_USER=$$a perl export-fleets.pl ; \
		REMOTE_USER=$$a perl export-dbs.pl ; \
	done
updaterank:
#		REMOTE_USER=$$a perl rank.pl > html/ranking.$$a.html ; \
		#REMOTE_USER=$$a perl holes.pl > html/$$a-holes.html ; 

updatespy:
	for a in $(allies) ; do \
		REMOTE_USER=$$a perl findspy.pl > html/alli/$$a/spies.csv ; \
	done
	
drawall:
	for f in www1.astrowars.com/export/history/starmap* ; do ./drawmap.pl $$f ; done

dumpdbs:
	-cp -a base/db2 /no_backup/bernhard/aw/backup/db-${mydate}
#	mkdir -p html/alli/$$a/history
#	-for a in $(allies) ; do \
#		cp -a html/alli/$$a/{fleets.csv,history/fleets-${mydate}.csv} ; \
#	done
#	cp -a ~/db olddb/
#	~/code/cvs/perl/dbm/show.pl ~/db/af-relation.dbm > dump/af-relation-`date +%y%m%d`
#	~/code/cvs/perl/dbm/show.pl ~/db/af-planets.dbm > dump/af-planets-`date +%y%m%d`

cleandbs:
	./cleanmysql.pl
	./cleanuseralli.pl > /dev/null
	#for a in $(allies) ; do REMOTE_USER=$$a ./cleanplanning.pl ; done
	cat empty.dbm > base/db2/sessioncache.dbm
showua:
	./showuseralli.pl
lookup7:
	perl -ne '@a=split("\t",$$_);if($$a[2]==$u){print}' player.csv.beta7
lookupa7:
	grep -n ^$a alliances.csv.beta7
af-relations.txt: ~/db/af-relation.dbm Makefile
	#../dbm/show.pl $< | grep = | sort -t= -k2 > $@
tgd-relations.txt: ~/db/tgd-relation.dbm Makefile
	#../dbm/show.pl $< | grep = | sort -t= -k2 > $@

topn:
	REMOTE_USER=af perl marktopn.pl $(topn) players.csv.beta*
TA.candidate: TA.in TA.done TA.pl
	./TA.pl > $@

chpasswd:
	REMOTE_USER=$a perl -e 'use http_auth; setdbpasswd("$p");'
	${htpasswd} -m -b ${htpasswdfile} $a $p

unaccess:
	mkdir -p old/obsolete
#	mv base/db2/$a-relation.dbm old/obsolete
	./removealli.pl $a
	vim +/^$a: ${htpasswdfile}

access:
	#-cp -ia empty.dbm base/db2/$a-relation.dbm
#	-cp -ia empty.dbm base/db2/$a-planets.dbm
	#touch base/db2/$a-relation.dbm.lock
#	./dbm-add.pl base/db2/$a-relation.dbm af "7 af alliance relation"
#	./dbm-add.pl base/db2/$a-relation.dbm rats "7 rats alliance relation"
	#./dbm-add.pl base/db2/$a-relation.dbm $a "9 $a own alliance relation"
	-addalli.pl
#	rm -rf large-$a ;	mkdir -p large-$a
	rm -rf html/alli/$a/l/ ; mkdir -p html/alli/$a/{l,history}
	${htpasswd} ${htpasswdfile} $a
	#vi /srv/www/cgi-bin/aw/.htaccess
	#-chmod 660 base/db2/$a*.dbm*
	#sudo chown wwwrun.bernhard base/db2/*.dbm*
	echo -n " $a" >> allowed_alliances # keep for human lookup only
	make reloadapache updatemap updatemap2 allies=$a

reloadapache:
	./reloadhttpd
	#sudo /usr/local/bin/reloadapache

tgz:
	rm -rf bmw-awtools
	mkdir bmw-awtools
	cp -a *.pl *.pm ${tools} prices.csv livemap preproc parse feed mangle ../brownie Makefile bmw-awtools
	cp -a --parent html/code/css/{tools,*.css} html/code/js html/images/aw bmw-awtools
	cd bmw-awtools &&\
	chmod 755 html && mkdir -p cgi-bin/public log &&\
	cp -a /home/aw/startup.pl ../dist-extra/* ../dist-extra/.ht* . &&\
	perl -i -pe 'if($$n){$$n--;$$_=""} if(m/greenbird 1/){$$n=2};' mangle/dispatch.pm &&\
	perl -i -pe 's/dbpasswd = .*/dbpasswd = "xxx";/; s/bmwuser/awuser/; ' DBConf.pm &&\
	find -name CVS -o -name ".*.swp" | xargs rm -rf &&\
	rm -rf nph-brownie.cgi holes2.pl mangle/special/secure.pm brownie/old preproc/www1.astrowars.com/zq*
	tar czf html/bmw-awtools-${mydate}.tar.gz bmw-awtools


relationspng:
	convert -density 70 html/round/alliancerelation-$(mydate).svg html/round/alliancerelation-$(mydate).png

