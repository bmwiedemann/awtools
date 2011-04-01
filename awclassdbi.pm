
package AW::DBI;
use DBConf;
use base 'Class::DBI';
AW::DBI->connection($DBConf::connectionInfo, $DBConf::dbuser, $DBConf::dbpasswd);


package AW::Fleet;
use base 'AW::DBI';
AW::Fleet->table('fleets');
AW::Fleet->columns(All => qw/fid alli status sidpid owner eta firstseen lastseen trn 	cls 	ds 	cs 	bs 	cv 	xcv 	iscurrent 	info/);
AW::Fleet->has_a(owner => AW::Player);


package AW::Player;
use base 'AW::DBI';
AW::Player->table('player');
AW::Player->columns(All => qw/pid 	points 	rank 	science 	culture 	level 	home_id 	logins 	trade 	country 	joined 	alliance 	name 	arank 	joinn 	opop 	otr/);
AW::Player->has_many(fleets => 'AW::Fleet');
AW::Player->has_many(planets => 'AW::Planet');
AW::Player->has_a(home_id=> 'AW::Starsystem');
AW::Player->has_a(alliance=> 'AW::Alliance');


package AW::Starsystem;
use base 'AW::DBI';
AW::Starsystem->table('starmap');
AW::Starsystem->columns(All => qw/sid 	x 	y 	level 	name/);


package AW::Planet;
use base 'AW::DBI';
AW::Planet->table('planets');
AW::Planet->columns(All => qw/sidpid 	population 	opop 	starbase 	ownerid 	siege/);
AW::Planet->has_a(ownerid => 'AW::Player');


package AW::Alliance;
use base 'AW::DBI';
AW::Alliance->table('alliances');
AW::Alliance->columns(All => qw/aid 	tag 	founder 	daysleft 	members 	points 	permanent 	name 	url/);
AW::Alliance->has_a(founder=> 'AW::Player');
AW::Alliance->has_many(players=> 'AW::Player');
AW::Alliance->has_many(delegates=> 'AW::Alliaccess');


package AW::Alliaccess;
use base 'AW::DBI';
AW::Alliaccess->table('alliaccess');
AW::Alliaccess->columns(All => qw'pid alliance');
AW::Alliaccess->has_a(pid => 'AW::Player');
AW::Alliaccess->has_a(alliance => 'AW::Alliance');


package AW::BestGuarded;
use base 'AW::DBI';
AW::BestGuarded->table('bestguarded');
AW::BestGuarded->columns(All => qw'sidpid time cv');

