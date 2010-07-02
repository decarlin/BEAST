#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

package BrowseTab;

use strict;
use warnings;
use lib "/projects/sysbio/map/Projects/BEAST/perllib";
use htmlHelper;
use BEAST::BeastDB;
use BEAST::Search;
use Data::Dumper;

our $TRUE = 1;
our $FALSE = 0;

###
### Build the Browse Tab
###

sub new
{
	my $class = shift;
	my $self = {
		_data_ref 	=> shift,
		_input 		=> shift,
	};

	bless $self, $class;
	return $self;
}

sub validateSearchResults
{
	my @results = @_;

	if (!ref($results[0])) {
		print "<br>No Sets Found<br>";
		return 0;
	}

	return 1;
}

sub printBrowseTab
{
	# hash ref to the input form data
	my $self = shift;
	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings
	my $checkboxdata = $self->{'_data_ref'};
	my $input = $self->{'_input'};

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

	## Create Form element and the rest...
	print <<EOF;
	<form id="searchcategories">
	<input type='button' value="Select/Deselect All" onclick="checkAll('searchcategories');">
	<b> Search: </b><input type='text' name="searchtext" value="$searchtext" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='browse' onClick="return onSearchSets();">
EOF

	my @checked;
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}

	foreach (keys %$checkboxdata) {
	  my $key = $_;
	  htmlHelper::beginSection($key, 'FALSE');
	  foreach (@{$checkboxdata->{$key}}) { 
		my $name = $_;
		my $checkedon = "";
		if (grep(/$key\:$name/, @checked)) {
			$checkedon = "checked='yes'";
		}
		print "<input type=checkbox name=\"$key:$name\" $checkedon>$name<br>\n";
	  }
	  htmlHelper::endSection($key);
	}

	unless ($searchtext eq "") {
		print "<br>";
		chomp($searchtext);
	
		my $beastDB = BeastDB->new;
		$beastDB->connectDB();
		my $treeBuilder = Search->new($beastDB);

		my @top_level_nodes = $treeBuilder->findParentsForSetByExtID($searchtext);
		if (validateSearchResults(@top_level_nodes) > 0) {	
			MySets::displaySets(@top_level_nodes);
		}

		$beastDB->disconnectDB();
	}

	print <<EOF;
	</form>
EOF


}

1;
