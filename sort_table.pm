package sort_table;
use strict;
require 5.002;

require Exporter;
our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
$VERSION = sprintf "%d.%03d", q$Revision$ =~ /(\d+)/g;
@ISA = qw(Exporter);
@EXPORT = qw(
&display_string &sort_num &sort_string &sort_table &sort_param_to_keys
);
use awstandard;
use CGI qw":standard";

# this file defines functions to output a sorted table.

sub display_string($) { $_[0]; }


sub sort_num($$) {$_[0]<=>$_[1]}
sub sort_string($$) {$_[0] cmp $_[1]}


sub sort_table(@@@) { my($header, $displayfunc, $sortfunc, $sortkeys, $data)=@_;
   my $headerstr="<table><tr>";
   {
      my $n=0;
      foreach(@$header) {
         next if not defined $$displayfunc[$n++];
         my $sortlinks="";
         for(0,1) {
            my $updown=$_?"up":"dn";
            my @newkeys=@$sortkeys;
            # TODO  test if new value is already present -> drop old
            unshift(@newkeys, $n*($_*2-1));
            my $sortval=join(".",@newkeys);
            my $oldparams=$ENV{QUERY_STRING};
            $oldparams=~s/sort=[-.0-9]*&?//;
            if($oldparams) {$oldparams="&$oldparams"}
            $sortlinks.=a({-href=>"?sort=$sortval$oldparams"},img({-src=>"/images/ico_arrow_$updown.gif", -alt=>"sort $updown", -style=>"border:0"}));
         }
         if(! defined ($$sortfunc[$n-1])) {$sortlinks=""}
         $headerstr.=th($_.$sortlinks);
      }
   }
   $headerstr.="</tr>\n";
   my $outstr="";
   my $line=0;
   foreach my $row (sort 
         {
            foreach(@$sortkeys) {
               my $sk=abs($_)-1; # actual sort key
               my $sf=$$sortfunc[$sk];
               if(!$sf) {$sf=\&sort_string}
               my $cmp=&$sf($$a[$sk], $$b[$sk]);
               if($cmp) {
                  return $cmp if $_>0;
                  return -$cmp;
               }
            }
            return 0;
         }
         @$data) {
      $outstr.="<tr class=\"".((++$line&1)?"odd":"even")."\">";
      my $n=0;
      foreach my $element (@$row) {
         my $df=$$displayfunc[$n++];
         next if not defined $df;
         $outstr.=td({-class=>"sort"},&$df($element));
      }
      $outstr.="</tr>\n";
   }
   return $headerstr.$outstr."</table>";
}

# this takes a CGI argument and converts it into a sortkeys arrayref 
# suitable for use with sort_table function
sub sort_param_to_keys($) { my($param)=@_;
   return [split(/\./,$param)];
}

1;