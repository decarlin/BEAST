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
		_input 		=> shift,
	};

	bless $self, $class;
	return $self;
}

sub validateSearchResults
{
	my @results = @_;

	if ( $#results == -1 || (!ref($results[0]))) {
		print "<br>No Sets Found<br>";
		return 0;
	}

	return 1;
}

sub printBrowseTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift;
	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings

	## build search meta terms
	# At some point we should get this out of the database
	my $checkboxdata = { 'Kind' => [ 'GO_Terms' ] };

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

		my @searches = split (/,/, $searchtext);	
		my $beastDB = BeastDB->new;
		$beastDB->connectDB();
		my $treeBuilder = Search->new($beastDB);

		my @results;
		foreach (@searches) {
			my $search = $_;

			my @top_level_nodes = $treeBuilder->findParentsByTerm($search);
			#my @top_level_nodes = $treeBuilder->findParentsForSetByExtID($search);
			foreach (@top_level_nodes) {
				my $node = $_;
				if (ref($node) eq 'Set') {
					push @results, $node;
				}
			}
		}

		my $merged_results = {};
		if ($#results > -1) {
			# results are a bunch of sets

			foreach my $i (0 .. $#results) {

				# foreach result - merge every other result to it
				# then add it to the hash 
				# this will add the result with all the nodes of the same name
				my $name = $results[$i]->get_name;
				next if (exists $merged_results->{$name});

				# this top-level node isn't yet saved -- find all other
				# mergeable trees, then add it to the results
				foreach my $j (0 .. $#results) {
					next if ($i eq $j);
					$results[$i]->mergeTree($results[$j]);
				}
				$merged_results->{$name} = $results[$i];
			}	
		}

		my @merged = ();
		foreach (keys %$merged_results) {
			push @merged, $merged_results->{$_};
		}

		if (validateSearchResults(@merged) > 0) {	
			MySets::displaySets("browse", @merged);
		}
		
		#my $Rsize = scalar (@results);
		#my $Msize = scalar (@merged);
		#print "merged into $Rsize into $Msize";
		BeastSession::saveSearchResults($session, @merged);

		$beastDB->disconnectDB();
	}


	print <<EOF;
	<input type='button' value='Add To My Sets' onClick="return onAddBrowseSets(this.form);"><br>
	</form>
EOF


}

1;
