d=`date +%d-%m-%Y`
f2=www1.astrowars.com/export/history/all$d.tar.bz2
all: test
test:
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 ; do ./arrival.pl -p $$i ; done
system-ids.txt:
	grep 303030 ~/public_html/aw/id.html | perl -ne 'm%>([^>]*)</td>%;print $1,"\n"' > ~/code/cvs/perl/awcalc/system-ids.txt
updatecsv: dumpdbs
	wget -x -nc -o/dev/null http://${f2}
	tar xjf ${f2}
	#for f in alliances starmap player planets ; do f2=www1.astrowars.com/export/history/$$f`date +%d-%m-%Y`.tar.bz2 ; wget -x -nc http://$$f2 ; tar xjf $$f2 ; done
	#mv db/*.mldbm* olddb/
	#perl importcsv.pl || cp -a olddb/*.mldbm* db/
	perl importcsv.pl && ( mv db/* olddb ; mv newdb/* db )
	cp -a tactical-af.png olddb/tactical-af-$d.png
updatemap: updaterank af-relations.txt tgd-relations.txt
	/usr/bin/nice -n +12 perl drawtactical.pl
	REMOTE_USER=tgd /usr/bin/nice -n +12 perl drawtactical.pl
updatemap2:
	/usr/bin/nice -n +12 perl tabmap.pl
	REMOTE_USER=tgd /usr/bin/nice -n +12 perl tabmap.pl
updaterank:
	REMOTE_USER=tgd perl rank.pl | sort -r > ranking.tgd.txt
	REMOTE_USER=af perl rank.pl | sort -r > ranking.af.txt
	
drawall:
	for f in www1.astrowars.com/export/history/starmap* ; do ./drawmap.pl $$f ; done

dumpdbs:
	~/code/cvs/perl/dbm/show.pl ~/db/af-relation.dbm > dump/af-relation-`date +%y%m%d`
	~/code/cvs/perl/dbm/show.pl ~/db/af-planets.dbm > dump/af-planets-`date +%y%m%d`
lookup7:
	perl -ne '@a=split("\t",$$_);if($$a[2]==$u){print}' player.csv.beta7
lookupa7:
	grep -n ^$a alliances.csv.beta7
af-relations.txt: ~/db/af-relation.dbm Makefile
	../dbm/show.pl $< | grep = | sort -t= -k2 > $@
tgd-relations.txt: ~/db/tgd-relation.dbm Makefile
	../dbm/show.pl $< | grep = | sort -t= -k2 > $@

