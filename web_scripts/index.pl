#!/usr/bin/perl -w
#################################
#######     index.pl       #######
#################################

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);	#the die could be used safely in web envrionment
use Data::Dumper;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use htmlHelper;
use BEAST::CheckBoxTree;
use BEAST::BrowseTab;
use BEAST::ImportTab;
use BEAST::MySets;
use BEAST::Set;

# global variable
our $input = new CGI();
our @sets;

sub doTabbedMenu();
sub doImportTab();
sub doSearchResult();
sub doMySets();

my $browseObj;
my $importObj;

#main
{
	print $input->header();

	# debug

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	my $browseSearchFilterCheckboxes = {
		'Species' 	=> ['Human', 'Mouse', 'Platypus'],
		'Kind'		=> ['Coexpression', 'Annotation']
	};
	$browseObj = BrowseTab->new($browseSearchFilterCheckboxes,$input);
	$importObj = ImportTab->new($input);

	if ($input->param('browse')) {
		# replace the browse tab to include the search results

		$browseObj->printBrowseTab();
		doSearchResult();
	} elsif ($input->param('import')) {
		$importObj->printImportTab();
	} elsif ($input->param('mysets')) {
		doMySets();
	} else {
		# default; on page creation	
		doTabbedMenu();	
	}

	#my $activetab = $input->param('tab');	
	#my $selected = 1;
	#if ($activetab == 'browse') {
	#	$selected = 2;
	#}

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
			\$("#mysets").tabs();
		}
	);
</script>

<div class="mysets_div" id="mysets">
	<ul>
		<li><a href="#mysets">MySets</a></li>
	</ul>
	<div id="mysets">
EOF
	doMySets();
print "</div>";

print <<EOF;
</div>
<div class="myopstabs_div" id="tabs">
	<ul>
		<li><a href="#import">Import</a></li>
		<li><a href="#browse">Browse</a></li>
		<li><a href="http://sysbio.soe.ucsc.edu/BEAST/admin_pages/admin.html">Admin</a></li>
	</ul>
EOF

	print "<div id=\"import\">";
	$importObj->printImportTab();
	print "</div>";

	print "<div id=\"browse\">";
	$browseObj->printBrowseTab();
	print "</div>";

	print "<div id=\"admin\">";
	print "</div>";
print "</div>";
}

sub doMySets()
{
	# build a drop down, hierarchical list of the current sets in the working
	# environment, sorted 

	# bullshit test data...
	
	my @sets;	
	my $gmSet = Set->new(
		'GeneralMills', 
		1,
		{ 'type' => 'manuf' }, 
		{ 
			'Cheerios' 	=> 1, 
			'Trix'		=> 0,
			'Wheaties'	=> 1 
		}
	);
	my $set1 = Set->new(
		'Bread', 
		1,
		{ 'type' => 'food' }, 
		{ 
			'Rye' => 1, 
			'Wheat' => 0, 
			'Sourdough' => 0 
		}
	);
	my $set2 = Set->new(
		'Cereal', 
		0,
		{ 'type' => 'food' }, 
		{ 
			'RiceCrispies' => 1, 
			'CocoPuffs' => 1, 
			$gmSet->get_name => $gmSet,
		}
	);

	
	push @sets, $set1;
	push @sets, $set2;

	print "<form id=\"mysetsform\">";

	MySets::display_my_sets(@sets);

	print "<input type='button' value='Update' onClick=\"return onUpdateMySets(this.form);\"><br>";
	print "</form>";

}

sub doSearchResult()
{
	print <<EOF;
	<br><b>Search Results:</b><br>
EOF
}


