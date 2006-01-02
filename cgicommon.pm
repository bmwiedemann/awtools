# to be included after input.pm or standard.pm in all CGIs
$::style=cookie('style');
$::timezone=cookie('tz');
if(!defined($::timezone)) {$::timezone=1}
1;
