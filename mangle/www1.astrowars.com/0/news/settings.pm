if($::options{pid}) {
	my $prefs=getuserprefs($::options{pid});
	my $prefsflags=$prefs->[8];
	my $immediate=($prefsflags&1);
	my $immediatecheck=$immediate?"checked":"";

	my $browniesettings=qq{<fieldset><legend>brownie settings</legend> <label for="immediatebuild">immediatebuild</label><input type="checkbox" id="immediatebuild" name="immediatebuild" $immediatecheck/><br/></fieldset>};
	s{<fieldset>\s*<legend>Password}{$browniesettings$&};
	s{http:(//status.icq.com)}{https:$1};
}

1;
