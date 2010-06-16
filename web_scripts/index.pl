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

# global variable
our $input = new CGI();
my $results;

sub doTabbedMenu();
sub doImportTab();
sub doSearchResult();
sub doMySets();

my $browseObj;

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
#print Data::Dumper->Dump([$browseObj]);

	if ($input->param('browse')) {
		# replace the browse tab to include the search results

		$browseObj->printBrowseTab();
		doSearchResult();
	} elsif ($input->param('import')) {
		doImportTab();
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
	</ul>
EOF

	print "<div id=\"import\">";
	doImportTab();
	print "</div>";
	print "<div id=\"browse\">";
	$browseObj->printBrowseTab();
	print "</div>";
print "</div>";
}

sub doImportTab()
{
	my $importtext = "";

	if ($input->param('importtype') eq 'text') {
		if ($input->param('importtext')) {
			$importtext = $input->param('importtext');
		}
	} else {
		#my $uploaded_filehandle = $input->upload('importtext');
	}

	print <<EOF;
	<form id="importform">
        <p class='radiO_selectors' id='textStyle'> 
	<input type='radio' name='importType' checked='checked' value='text' onclick='chooseTextImport(this.form)'>
	Enter sets to import
	</p>	
	<textarea name="importtext" id="setsImportFromText" cols="40" rows="5">$importtext</textarea><br>
	<p>
        <p class='radiO_selectors' id='fileStyle'> 
	<input type='radio' name='importType' value='file' onclick='chooseFileImport(this.form)'>
	Or import from a local file:
	</p>
	<input type='hidden' name='MAX_FILE_SIZE" value='200'>
	<input type='file' name="importtext" accept="text" id="setsImportFromFile" value="file" onclick="selectImportFile(this.form)">
	<input type='button' value='import' onClick="return onImportSets(this.form);"><br>
	</form>
		<p>Search Box here....</p>
EOF
}

sub doMySets()
{
	# build a drop down, hierarchical list of the current sets in the working
	# environment, sorted 

	# bullshit test data...
	my $data = {
		'Bread' 	=> ['Rye', 'Wheat', 'Sourdough'],
		'Cereal'	=> ['RiceCrispies', 'CocoPuffs'],
		'Cars' 		=> { 'Honda' => ['Civic','Accord']}
	};
	CheckBoxTree::buildCheckBoxTree($data, "");
}

sub doSearchResult()
{
	print <<EOF;
	<br><b>Search Results:</b><br>
EOF
}


