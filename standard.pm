our $server="www1.astrowars.com";
our @month=qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our %relationname=(1=>"total war", 2=>"foe", 3=>"tense", 4=>"unknown(neutral)", 5=>"implicit neutral", 6=>"NAP", 7=>"friend", 8=>"ally", 9=>"member");
our %planetstatusstring=(1=>"unknown", 2=>"planned by", 3=>"targeted by", 4=>"sieged by", 5=>"taken by", 6=>"lost to", 7=>"defended by");



sub AWheader2($) { my($title)=@_;
	start_html($title). a({href=>"index.html"}, "AW tools index"). h1($title);
}
sub AWheader($) { my($title)=@_; header.AWheader2($title);}

sub mon2id($) {my($m)=@_;
        for(my $i=0; $i<12; $i++) {
                if($m eq $month[$i]) {return $i}
        }
}

sub parseawdate($) {my($d)=@_;
        return undef if($d!~/(\d\d):(\d\d):(\d\d)\s-\s(\w{3})\s(\d+)/);
        return timegm($3,$2,$1,$5, mon2id($4), (gmtime())[5]);
}

sub getrelationcolor($) { my($rel)=@_;
        if(!$rel) { $rel=4; }
        ("", "Firebrick", "OrangeRed", "orange", "grey", "navy", "RoyalBlue", "Turquoise", "lightgreen", "green")[$rel];
}

sub getstatuscolor($) { my($s)=@_; if(!$s) {$s=1}
        (qw(black black blue cyan red green orange green))[$s];
}
# http://www.iconbazaar.com/color_tables/lepihce.html

sub planetlink($) {my ($id)=@_;
        my $escaped=$id;
        $escaped=~s/#/%23/;
        return qq!<a href="planet-info?id=$escaped">$id</a>!;
}
sub profilelink($) { my($id)=@_;
        qq!<a href="http://$::server/about/playerprofile.php?id=$id"><img src="/images/aw/profile1.gif" title="public"></a> <a href="http://$::server/0/Player/Profile.php/?id=$id"><img src="/images/aw/profile2.gif"></a>\n!;
}
sub alliancedetailslink($) { my($id)=@_;
        qq!<a href="http://$::server/0/Alliance/Detail.php/?id=$id"><img src="/images/aw/profile3.gif"></a>\n!;
}
sub systemlink($) { my($id)=@_;
        qq!<a href="system-info?id=$id">info for system $id</a>\n!;
}

1;
