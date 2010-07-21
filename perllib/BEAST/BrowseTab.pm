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

sub buildSearchOpts
{
	my $searchopts = shift;
	my $checkboxdata = shift;
}

sub printBrowseTab
{
	# hash ref to the input form data
	my $self = shift;
	my $session = shift || undef;

	if (defined $session) {
		die unless (ref($session) eq 'CGI::Session');
	}
	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings

	## build search meta terms
	# At some point we should get this out of the database

	# build these from checkbox options
	my $searchopts = {
		'keyspace' => { 
			'organism' => [ 'mouse', 'human' ],	
			'source'   => [ 'entrez' ],
		},
	};

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
	print <<MULTILINE_STR;
	<form id="searchcategories">
	<input type='button' value="Select/Deselect All" onclick="checkAll('searchcategories');">
	<b> Search: </b><input type='text' name="searchtext" value="$searchtext" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='browse' onClick="return onSearchSets();">
MULTILINE_STR

	my @checked;
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}

	my $at_least_one_checked = $FALSE;
	my $at_least_one_unchecked = $FALSE;

	my $checkedopts = {'keyspace' => {}};
	foreach (keys %{$searchopts->{'keyspace'}}) {
	  my $key = $_;
	  htmlHelper::beginSection($key, 'FALSE');
	  foreach (@{$searchopts->{'keyspace'}->{$key}}) { 
		my $name = $_;
		my $checkedon = "";
		if (grep(/$key\:$name/, @checked)) {
			$at_least_one_checked = $TRUE;
			$checkedon = "checked='yes'";
			my @chk;
			if (exists $checkedopts->{'keyspace'}->{$key}) {
				@chk = @{$checkedopts->{'keyspace'}->{$key}};
				$checkedopts->{'keyspace'}->{$key} = [ @chk, $name ];
			} else {
				$checkedopts->{'keyspace'}->{$key} = [ $name ];
			}
		} else {
			$at_least_one_unchecked = $TRUE;
		}

		print "<input type=checkbox name=\"$key:$name\" $checkedon>$name<br>\n";
	  }
	  htmlHelper::endSection($key);
	}

	my $FULL_SEARCH = $FALSE;
	if (($at_least_one_checked == $FALSE) || ($at_least_one_unchecked == $FALSE)) {
		$FULL_SEARCH = $TRUE;
	}

	unless ($searchtext eq "") {
		print "<br>";
		chomp($searchtext);

		my $beastDB = BeastDB->new;
		$beastDB->connectDB();
		my $treeBuilder = Search->new($beastDB);

		my @merged;
		if ($FULL_SEARCH == $TRUE) {
			@merged = $treeBuilder->searchOnSetDescriptions($searchtext);
		} else {
			@merged = $treeBuilder->searchOnSetDescriptions($searchtext, $checkedopts);
		}

		if (validateSearchResults(@merged) > 0) {	
			MySets::displaySetsTree("browse", @merged);
			#my $Rsize = scalar (@results);
			#my $Msize = scalar (@merged);
			#print "merged into $Rsize into $Msize";
			BeastSession::saveSetsToSession($session, 'browsesets', @merged);
		}
		
		$beastDB->disconnectDB();
	}


	print <<MULTILINE_STR;
	<input type='button' value='Add To My Sets' onClick="return onAddBrowseSets(this.form);"><br>
	</form>
MULTILINE_STR


}

1;
