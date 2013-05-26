#!/usr/bin/perl
use strict;
use lib qw(/home/aw/inc /home/aw/base); # still needed
chdir "/home/aw/inc";      # still needed
use Apache::DBI;          # for speedup of mysql access with persistent conn
use Apache2::Access;       # for $r->get_basic_auth_pw
use Apache2::RequestIO (); # for $r->print
use Apache2::RequestUtil (); # speedup
use Apache2::Const ":common";
use APR::Table;           # for $headers->unset
use CGI;
use Tie::DBI;
use LWP::UserAgent ();
use LWP::ConnCache;

use apacheconst;
use DBConf;
use awinput;
use awimessage;
#use Apache2;
#Apache::DBI->connect_on_init($DBConf::connectionInfo,$DBConf::dbuser,$DBConf::dbpasswd);
Apache::DBI->setPingTimeOut($DBConf::connectionInfo, -1);

if(0) {
open(DEBUG, ">", "/tmp/debug123");
print DEBUG scalar localtime(),"\n";
close DEBUG;
}

1;
