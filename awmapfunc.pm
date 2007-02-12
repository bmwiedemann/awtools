# this module does no graphics itself, but delivers map data in a standardized format

package awmapfunc;
use strict;
use warnings;
use awstandard;
use awinput;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(&awrelationfunc &awpopulationfunc &awplanfunc &awsiegefunc &awfilterchain &awfleetstatusfunc &awfleetownerrelationfunc);

my $s=12;

# all mapping functions:
# input: x,y coords
# input: systemID
# input: planetID
# output: array of [array width(pixels), color]

sub mrelationcolor($) { my($name)=@_;
	my @rel=getrelation($name);
	my $color=getrelationcolor($rel[0]);
	$color=~s/black/white/;
	return $color;
}
sub mrelationcolorid($) {
	mrelationcolor(playerid2name($_[0])); 
}
sub mrelationcolorid2($) {
	my($ownerid)=@_;
	if(defined($ownerid) && $ownerid>2) {
		return mrelationcolorid($ownerid);
	} 
	return defined($ownerid)?"white":"dimgray";
}

# input: array ref, width (in pixels)
sub shrinkv
{
	my($v,$w)=@_;
	if(@$v == 0) {
		$_[1]=$s;
		return;
	}
	my $taken=0;
	foreach my $e (@$v) {
		my $we=$e->[0];
		my $take=awmin($w-$taken, awmin($we-1, bmwround($w*$we/$s)));
		$e->[0]-=$take;
		$taken+=$take;
	}
	$_[1]=$taken; # because we might have allocated less space than wanted
}

sub addleft
{
	my($v,$w,$c)=@_;
	shrinkv($v,$w);
#	$v->[0][0]-=$w;
	unshift(@$v, [$w,$c]);
}

sub noaddright(@$$) # rescale a line even if there was nothing to add
{
	my($v,$w)=@_;
	shrinkv($v,$w);
	if(@$v==0) {@$v=([$w,"white"])}
	$v->[$#{$v}][0]+=$w;
}
sub addright(@$$)
{
	my($v,$w,$c)=@_;
	shrinkv($v,$w);
#	$v->[$#{$v}][0]-=$w;
	push(@$v, [$w,$c]);
}

sub addafter
{
	my($v,$i,$w,$c)=@_;
	shrinkv($v,$w);
#	$v->[0][$i]-=$w;
	splice(@$v, $i+1, 0, [$w,$c]);
}

# mapping functions:

sub awrelationfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my $planet=getplanet($sid, $pid); 
	my $ownerid=$$planet{ownerid};
	my $color=mrelationcolorid2($ownerid);
	addleft(\@v, 4, $color);
	return @v;
}

sub awpopulationfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my $planet=getplanet($sid, $pid);
	use constant maxpop => 25;
	my $c;
   if(!$planet) {$c="dimgray"}
   else {
      my $pop=awmin(maxpop,$$planet{pop});
      if($$planet{ownerid}==0) {$c="blue"}
      else {
         my $l=$pop*255/maxpop;
         $c=((255-$l)<<16)|($l<<8);
      }
   }
	addleft(\@v, 4, $c);
	return @v;
}

my %fleetstatusmap=(0=>"red",1=>0x008800,2=>"orange",3=>"cyan");
# display defending, sieging, incoming and own moving fleets
sub awfleetstatusfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
   my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $alli=$ENV{REMOTE_USER};
	my $allimatch=awinput::get_alli_match($alli);
   my $sth=$DBAccess::dbh->prepare_cached("
		SELECT `status`,`cv` 
		FROM `fleets` 
		WHERE ($allimatch) AND `sidpid` = ? AND `iscurrent` = 1  
		ORDER BY `xcv`");
	my $res=$DBAccess::dbh->selectall_arrayref($sth, {}, $sidpid);
	foreach my $row (@$res) {
		my ($s,$cv)=@$row;
#		print "$pid $s\n";
		my $c=$fleetstatusmap{$s};
		if($cv==0){$c="black"}
		addleft(\@v,3, $c);
	}
	return @v;
}

sub awfleetownerrelationfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
   my $sidpid=sidpid22sidpid3m($sid,$pid);
	my $alli=$ENV{REMOTE_USER};
	my $allimatch=awinput::get_alli_match($alli);
   my $sth=$DBAccess::dbh->prepare_cached("
		SELECT `owner`
		FROM `fleets` 
		WHERE ($allimatch) AND `sidpid` = ? AND `iscurrent` = 1 AND `cv` > 0 
		ORDER BY `xcv`");
	my $res=$DBAccess::dbh->selectall_arrayref($sth, {}, $sidpid);
	foreach my $row (@$res) {
		my $ownerid=$$row[0];
#		print "$pid $o\n";
		addright(\@v,3, mrelationcolorid2($ownerid));
	}
	return @v;
}


sub awsiegefunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my $planet=getplanet($sid, $pid); 
	if(planet2siege($planet)) {
		addright(\@v, 3,"red");
	}
	return @v;
}

sub awplanfunc
{ my($x,$y,$sid,$pid,$data)=@_;
	my @v=awfilterchain($x,$y,$sid,$pid,$data);
	my @pinfo=getplanetinfo($sid, $pid);
	if(@pinfo) {
	   my $c=getstatuscolor($pinfo[0]);
		addright(\@v, 4, $c);
	} else {noaddright(\@v,4)}
	return @v;
}

sub awfilterchain
{ my($x,$y,$sid,$pid,$data)=@_;
	my @d=$data?@$data:(); # need to copy to not modify original data and allow use for later calls
	my $filt=pop(@d);
	if(!$filt) {return ()} # base coloring as fallback
	return &$filt($x,$y,$sid,$pid,\@d);
}

1;
