all: test

test:
	ls in/secure-* | xargs -L1 ./awread.pl
tar:
	tar cjf awread.tar.bz2 awread.pl in digits
