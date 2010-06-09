#!/usr/bin/perl -w
#################################
#######     sandbox.pl       #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment
use Data::Dumper;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use htmlHelper;

my $input = new CGI();
my $results;

sub doFilterCategories($);

#main
{
	print $input->header();

	# debug
	#print Data::Dumper->Dump([$input]);

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	doFilterCategories(\$input);	

	my $timestamp = localtime;
	print "<br><div class='footer'>$timestamp</div>";

#	printFooter();
}# end main




sub doFilterCategories()
{
	my $input = ${(shift)};

	my $activetab = $input->param('tab');	
	my $selected = 1;
	if ($activetab == 'browse') {
		$selected = 2;
	}
		
# Create Jquery tabbed box with 2 tabs
	print <<EOF;
<script type="text/javascript">

	\$(
		function()
		{
			\$("#tabs").tabs($selected);
		}
	);
</script>


<div id="tabs">
	<ul>
		<li><a href="#tabs-1">Import</a></li>
		<li><a href="#tabs-2">Browse</a></li>
	</ul>
	<div id="tabs-1">	
		<p>Search Box here....</p>
	</div>
	<div id="tabs-2">

EOF
# In the second tab: add dropdown filter/search arrow
# menu


	print <<EOF;
	<form id="searchcategories" onSubmit="return onSearchSets();" >
	<input type='button' value="Select/Deselect All" onclick="checkAll('searchcategories');">
	<b> Search: </b><input type='text' name="searchtext" value="" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='submit' name='activetab' value='browse'">
EOF

	my $data = {
		'Species' 	=> ['Human', 'Mouse', 'Platypus'],
		'Kind'		=> ['Coexpression', 'Annotation']
	};

	foreach (keys %$data) {
	  my $key = $_;
	  htmlHelper::beginSection($key, FALSE);
	  foreach (@{$data->{$key}}) { 
		my $checked = "";
		if ( $input->param($key.$_) && $input->param($key.$_) == 'on') {
			$checked = "checked='yes'";
		}
		print "<input type=checkbox name=\"$key:$_\" $checked>$_<br>\n";
	  }
	  htmlHelper::endSection($key);
	}

	print <<EOF;
	</form>
	</div> <!-- tabs-2 -->
</div>  <!-- tabs -->
<!-- end of tabs -->
EOF
	
}

