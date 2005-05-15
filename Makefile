d=`date +%d-%m-%Y`
f2=www1.astrowars.com/export/history/all$d.tar.bz2
topn=500
allies=af fun tgd xr la tbgsaf guest
#allies=
#winterwolf arnaken manindamix
all: TA.candidate
test:
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 ; do ./arrival.pl -p $$i ; done
system-ids.txt:
	grep 303030 ~/public_html/aw/id.html | perl -ne 'm%>([^>]*)</td>%;print $1,"\n"' > ~/code/cvs/perl/awcalc/system-ids.txt
updatecsv: dumpdbs
	wget -x -nc -o/dev/null http://${f2}
	tar xjf ${f2}
	umask 2 ; perl importcsv.pl && ( mv db/* olddb ; mv newdb/* db )
	cp -a tactical-af.png olddb/tactical-af-$d.png
updatemap: updatemaponly updaterank af-relations.txt tgd-relations.txt
updatemaponly:
	for a in $(allies) ; do \
	REMOTE_USER=$$a /usr/bin/nice -n +12 perl drawtactical.pl ; done
updatemap2: cleandbs updatemap2only
updatemap2only:
	for a in $(allies) ; do \
		REMOTE_USER=$$a /usr/bin/nice -n +12 perl tabmap.pl ; \
	done
updaterank:
	for a in $(allies) ; do \
		REMOTE_USER=$$a perl rank.pl | sort -r > html/ranking.$$a.txt ; \
		REMOTE_USER=$$a perl holes.pl > html/$$a-holes.html ; \
	done
	
drawall:
	for f in www1.astrowars.com/export/history/starmap* ; do ./drawmap.pl $$f ; done

dumpdbs:
	cp -a ~/db olddb/
	~/code/cvs/perl/dbm/show.pl ~/db/af-relation.dbm > dump/af-relation-`date +%y%m%d`
	~/code/cvs/perl/dbm/show.pl ~/db/af-planets.dbm > dump/af-planets-`date +%y%m%d`

cleandbs:
	for a in $(allies) ; do \
	   REMOTE_USER=$$a ./cleanplanning.pl ; done
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
	cp -ia ../dbm/empty.dbm ~/db/$a-relation.dbm
	cp -ia ../dbm/empty.dbm ~/db/$a-planets.dbm
	mkdir large-$a
	/usr/sbin/htpasswd2 ~/.htpasswd $a
	vi /srv/www/cgi-bin/aw/.htaccess
	-chmod 664 ~/db/$a*.dbm
	sudo chown wwwrun.bernhard /home/bernhard/db/*.dbm

tgz:
	tar -czf ../bmw-awtools.tar.gz *.pl *.pm TA.in TA.done system-info relations relations-bulk planet-info login tactical{,-large} alliance fleets feedupdate feed/*.pm LICENSE Makefile
	mv ../bmw-awtools.tar.gz html/
