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

sub doTabbedMenu();
sub doImportTab();
sub doBrowseTab();

#main
{
	print $input->header();

	# debug
	#print Data::Dumper->Dump([$input]);

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	if ($input->param('search')) {
		# replace the browse tab to include the search results
		doBrowseTab();
	} else {
		# default; on page creation	
		doTabbedMenu();	
	}

	#my $activetab = $input->param('tab');	
	#my $selected = 1;
	#if ($activetab == 'browse') {
	#	$selected = 2;
	#}

	my $timestamp = localtime;
	print "<br><div class='footer'>$timestamp</div>";

#	printFooter();
}# end main




sub doTabbedMenu()
{
		
# Create Jquery tabbed box with 2 tabs
	print <<EOF;
<script type="text/javascript">

	\$(
		function()
		{
			\$("#tabs").tabs();
		}
	);
</script>


<div id="tabs">
	<ul>
		<li><a href="#import">Import</a></li>
		<li><a href="#browse">Browse</a></li>
	</ul>
EOF

	print "<div id=\"import\">";
	doImportTab();
	print "</div>";
	print "<div id=\"browse\">";
	doBrowseTab();
	print "</div>";
print "</div>";
}

sub doImportTab()
{
	print <<EOF;
		<p>Search Box here....</p>
EOF
}

sub doBrowseTab() 
{

	print <<EOF;
	<form id="searchcategories">
	<input type='button' value="Select/Deselect All" onclick="checkAll('searchcategories');">
	<b> Search: </b><input type='text' name="searchtext" value="" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='browse' onClick="return onSearchSets();">
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
EOF
}

