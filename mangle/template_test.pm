use strict;
if($::options{name} eq "greenbird") {
   eval q§use strict;

      $_.="test OK";

   § or $_.= $@;
}

1;
