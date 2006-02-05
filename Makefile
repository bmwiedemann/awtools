d=`date +%d-%m-%Y`
mydate=`date +%y%m%d`
awserv=www1.astrowars.com
f2=www1.astrowars.com/export/history/all$d.tar.bz2
topn=500
round=gold3
allies=$(shell cat allowed_alliances)
tools=index.html preferences arrival authaw distsqr eta tactical{,-large{,-tile},-live} relations relations-bulk alliance{,2} system-info planet-info edit-fleet fleets feedupdatemangle feedupdate ranking sim topwars coord holes battles loginpos antispy tradepartners whocansee permanentranking adminuseralli logout
#allies=
#winterwolf arnaken manindamix tabouuu
all: TA.candidate
test:
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 ; do ./arrival.pl -p $$i ; done
links:
	ln -f ${tools} /srv/www/cgi-bin/aw/
	ln -f topwars /srv/www/cgi-bin/aw/topallis
system-ids.txt:
	grep 303030 ~/public_html/aw/id.html | perl -ne 'm%>([^>]*)</td>%;print $1,"\n"' > ~/code/cvs/perl/awcalc/system-ids.txt
updatecsv: dumpdbs
	wget -x -nc -o/dev/null http://${f2}
	tar xjf ${f2}
	umask 2 ; perl importcsv.pl && ( mv db/* olddb ; mv newdb/* db )
	#-cp -a tactical-af.png olddb/tactical-af-$d.png
	wget -o/dev/null http://${awserv}/rankings/bestguarded.php -O${awserv}/rankings/bestguarded-$d.html
	wget -o/dev/null http://${awserv}/rankings/strongestfleet.php -O${awserv}/rankings/strongestfleet-$d.html
	for i in 4 3 2 1 ; do mv html/strongestfleet-{$$i,`expr $$i + 1`}.html ; done
	perl manglestrongestfleet.pl www1.astrowars.com/rankings/strongestfleet-$d.html www1.astrowars.com/rankings/bestguarded-$d.html
	perl detectalliancerelation.pl > html/${round}/alliancerelation-${mydate}
	ln -f html/${round}/alliancerelation-${mydate} html/${round}/alliancerelation
	perl importcsv-mysql.pl

updatemap: updatemaponly updaterank af-relations.txt tgd-relations.txt
updatemapsonly: updatemaponly updatemap2only
updatemaponly:
	for a in $(allies) ; do \
	REMOTE_USER=$$a /usr/bin/nice -n +12 perl drawtactical.pl ; done
updatemap2: cleandbs updatemapsonly updatespy updateholes
updatemap2only:
	for a in $(allies) ; do \
		REMOTE_USER=$$a /usr/bin/nice -n +12 perl tabmap.pl ; \
	done
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
#	mkdir -p html/alli/$$a/history
	for a in $(allies) ; do \
		cp -a html/alli/$$a/{fleets.csv,history/fleets-${mydate}.csv} ; \
	done
#	cp -a ~/db olddb/
#	~/code/cvs/perl/dbm/show.pl ~/db/af-relation.dbm > dump/af-relation-`date +%y%m%d`
#	~/code/cvs/perl/dbm/show.pl ~/db/af-planets.dbm > dump/af-planets-`date +%y%m%d`

cleandbs:
	./cleanmysql.pl
#	for a in $(allies) ; do \
	   #REMOTE_USER=$$a ./cleanplanning.pl ; done
	cat ../dbm/empty.dbm > ~/db/sessioncache.dbm
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

access:
	-cp -ia ../dbm/empty.dbm ~/db/$a-relation.dbm
	-cp -ia ../dbm/empty.dbm ~/db/$a-planets.dbm
	touch ~/db/$a-planets.dbm.lock ~/db/$a-relation.dbm.lock
#	rm -rf large-$a ;	mkdir -p large-$a
	rm -rf html/alli/$a/l/ ; mkdir -p html/alli/$a/{l,history}
	/usr/sbin/htpasswd2 ~/.htpasswd $a
	#vi /srv/www/cgi-bin/aw/.htaccess
	-chmod 660 ~/db/$a*.dbm*
	sudo chown wwwrun.bernhard /home/bernhard/db/*.dbm*
	echo -n " $a" >> allowed_alliances
	make updatemap updatemap2 allies=$a

tgz:
	tar --exclude=DBConf.pm -czf html/bmw-awtools-${mydate}.tar.gz *.pl *.pm TA.in TA.done ${tools} feed/*.pm mangle/*.pm LICENSE Makefile

