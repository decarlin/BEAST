#!/usr/bin/perl -w
#Author:	Evan Paull (epaull@soe.ucsc.edu)
#Create Date:	6.16.2010

package SearchTab;

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
### Build the Search Tab
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

sub printTab
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
			'keyspace_organism' => [ 'mouse', 'human' ],	
			'keyspace_source'   => [ 'entrez' ],
		},
		'source' => [ 'go', 'chemdiv', 'boon_sga' ]
	};

	# build the searchopts as a tree
	my $mouse = Set->new('mouse', 1, {'type' => 'set'}, "");
	my $human = Set->new('human', 1, {'type' => 'set'}, "");
	my $keyspace_organism = Set->new('keyspace_organism', 1,{'type' => 'meta'}, {'mouse' => $mouse, 'human' => $human});

	my $entrez = Set->new('entrez', 1,{'type' => 'set'}, "");
	my $keyspace_source = Set->new('keyspace_source', 1, {'type' => 'meta'}, {'entrez' => $entrez});

	my $keyspace = Set->new('keyspace', 1, {'type' => 'meta'}, 
		{'keyspace_source' => $keyspace_source, 'keyspace_organism' => $keyspace_organism});

	my $go = Set->new('go', 1, {'type' => 'set'}, "");
	my $curated = Set->new('curated', 1, {'type' => 'meta'}, {'go' => $go});

	my $chemdiv = Set->new('chemdiv', 1, {'type' => 'set'}, "");
	my $boon_sga = Set->new('boon_sga', 1, {'type' => 'set'}, "");
	my $experimental = Set->new('experimental', 1, {'type' => 'meta'}, {'chemdiv' => $chemdiv, 'boon_sga' => $boon_sga});

	my $source = Set->new('source', 1, {'type' => 'meta'}, {'experimental' => $experimental, 'curated' => $curated});
	
	my $opts = Set->new('searchopts', 1, {'type' => 'meta'}, {'keyspace' => $keyspace, 'source' => $source});

	my @opts = ($opts);
	#MySets::displaySetsTree("search_opts", "", @opts);
	#print Data::Dumper->Dump([$opts]);

	# end build options

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
	<b> Filter: </b><input type='text' name="searchtext" value="$searchtext" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='filter' onClick="return onSearchSets();">
MULTILINE_STR

	my @checked;
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}

	my $at_least_one_checked = $FALSE;
	my $at_least_one_unchecked = $FALSE;

	# this is for the keyspace opts
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

	# for everything else
	foreach (keys %{$searchopts}) {
	  my $key = $_;
	  next if ($key =~ /keyspace/);
	  htmlHelper::beginSection($key, 'FALSE');
	  foreach (@{$searchopts->{$key}}) { 
		my $name = $_;
		my $checkedon = "";
		if (grep(/$key\:$name/, @checked)) {
			$at_least_one_checked = $TRUE;
			$checkedon = "checked='yes'";
			my @chk;
			if (exists $checkedopts->{$key}) {
				@chk = @{$checkedopts->{$key}};
				$checkedopts->{$key} = [ @chk, $name ];
			} else {
				$checkedopts->{$key} = [ $name ];
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
			print "<input type='button' value='Add To My Sets' onClick=\"return onAddSearchSets(this.form);\"><br>";
			MySets::displaySetsTree("search", "", @merged);
			#my $Rsize = scalar (@results);
			#my $Msize = scalar (@merged);
			#print "merged into $Rsize into $Msize";
			BeastSession::saveSetsToSession($session, 'searchsets', @merged);
		}
		
		$beastDB->disconnectDB();
	}


	print "</form>";
}

1;
