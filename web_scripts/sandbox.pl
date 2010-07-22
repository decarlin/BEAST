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

# global variable
our $input = new CGI();
my $results;

sub doTabbedMenu();
sub doImportTab();
sub doBrowseTab();
sub doSearchResult();
sub doMySets();

sub buildDropDown($$);

#main
{
	print $input->header();

	# debug
	# print Data::Dumper->Dump([$input]);

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	if ($input->param('browse')) {
		# replace the browse tab to include the search results
		doBrowseTab();
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
	print <<MULTILINE_STR;
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
MULTILINE_STR
	doMySets();
print "</div>";

print <<MULTILINE_STR;
</div>
<div class="myopstabs_div" id="tabs">
	<ul>
		<li><a href="#import">Import</a></li>
		<li><a href="#browse">Browse</a></li>
	</ul>
MULTILINE_STR

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
	my $importtext = "";

	if ($input->param('importtype') eq 'text') {
		if ($input->param('importtext')) {
			$importtext = $input->param('importtext');
		}
	} else {
		#my $uploaded_filehandle = $input->upload('importtext');
	}

	print <<MULTILINE_STR;
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
MULTILINE_STR
}

sub doBrowseTab() 
{
	my $searchtext = "";
	my @checked;

	if ($input->param('searchtext')) {
		$searchtext = $input->param('searchtext');
	}
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}

	# build search opts data structure
	my $activeFilters = {};
	foreach (@checked) {
		my ($category, $type) = split(/:/,$_);
		unless ($activeFilters->{$category}) { 
			$activeFilters->{$category} => []; 
		}
		push @{$activeFilters->{$category}}, $type;
	}

	print <<MULTILINE_STR;
	<form id="searchcategories">
	<input type='button' value="Select/Deselect All" onclick="checkAll('searchcategories');">
	<b> Search: </b><input type='text' name="searchtext" value="$searchtext" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='browse' onClick="return onSearchSets();">
MULTILINE_STR

	my $data = {
		'Species' 	=> ['Human', 'Mouse', 'Platypus'],
		'Kind'		=> ['Coexpression', 'Annotation']
	};

	my @checked;
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}

	foreach (keys %$data) {
	  my $key = $_;
	  htmlHelper::beginSection($key, FALSE);
	  foreach (@{$data->{$key}}) { 
		my $name = $_;
		my $checkedon = "";
		if (grep(/$key\:$name/, @checked)) {
			$checkedon = "checked='yes'";
		}
		print "<input type=checkbox name=\"$key:$name\" $checkedon>$name<br>\n";
	  }
	  htmlHelper::endSection($key);
	}

	print <<MULTILINE_STR;
	</form>
MULTILINE_STR
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
	buildDropDown($data, "");
}

sub doSearchResult()
{
	print <<MULTILINE_STR;
	<br><b>Search Results:</b><br>
MULTILINE_STR
}

###
### Build drop down list below this item
###
sub buildDropDown($$)
{
	my $dataRef = shift;
	my $key = shift;

	die "$dataRef not a hash ref!" unless (ref $dataRef eq 'HASH');
	my @keys;

	my $marginleft = "margin-left:20px;";

	unless ($key eq "") {
		$keys[0] = $key;
		if ($key =~ /:/) {
			@keys = split(/:/,$key);
			$marginleft = "margin-left:".(($#keys+2)*10)."px;";
		}
	}

	# dig down through the keys supplied, updating the reference through each
	my $ref = $dataRef;
	foreach (@keys) {
		$ref = $ref->{$_};	
	}

	unless ($key eq "") {
	  htmlHelper::beginTreeSection($key, FALSE);
	}

	my @list;

	if ($key eq "") { 
		# in this case we're starting at the top of the hash -- key is blank
		@list = keys %{$ref}; 
	} else {
		if (ref($ref) eq 'HASH') {
			@list = keys %$ref;
		} elsif (ref($ref) eq 'ARRAY') {
			@list = @{$ref};
		} elsif (ref($ref) eq 'SCALAR') {
			$list[0] = $ref;
		} else {
			die "Improper data type!";
		}
	}

	foreach (@list) { 

		my $name = $_;

		if (ref($ref) eq 'HASH') {
			## print another drop-down arrow, which includes a checkbox for 
			## this element as well
			my $index = ($key eq "") ? $name : "$key:$name";
			buildDropDown($dataRef, $index); 
		} else {
			## print the tag and move on
			print "<input style='$marginleft' type=checkbox name=\"";
			($key eq "") ? print $name : print "$key:$name";
			print "\">$name<br/>\n";
		}

	}
	unless ($key eq "") {
	  htmlHelper::endSection($key);
#	  print "<br><br>";
	}
}

