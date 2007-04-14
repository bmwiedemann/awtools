#
# abstract away differences between Apache from SuSE 9.3 and later Apache2
#
package apacheconst;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = 
qw(OK DECLINED AUTH_REQUIRED);

eval "use Apache::Const";
eval "use Apache2::Const";


1;
