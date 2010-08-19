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

	my $input = $self->{'_input'};

	my $searchtext = "";
	my @checked;

	if ($input->param('searchtext')) {
		$searchtext = $input->param('searchtext');
	}
	if ($input->param('checkedfilters[]')) {
		@checked = $input->param('checkedfilters[]');
	}
	my $checkedopts = {
		'mouse' => 0,
		'human' => 0,
		'entrez' => 0,
		'go' => 0,
		'chemdiv' => 0,
		'boon_sga' => 0,
	};
	foreach (@checked) {
		$_ =~ s/.*<>//g;
		$checkedopts->{$_} = 1;
	}

	# Search filter/checkbox categories to display
	# Hash reference: keys are refs to arrays of strings

	# build the searchopts as a tree
	my $mouse = Set->new('mouse', $checkedopts->{'mouse'}, {'type' => 'set_option'}, "");
	my $human = Set->new('human', $checkedopts->{'human'}, {'type' => 'set_option'}, "");
	my $keyspace_organism = Set->new('keyspace_organism', 1,{'type' => 'meta_option'}, {'mouse' => $mouse, 'human' => $human});

	my $entrez = Set->new('entrez', $checkedopts->{'entrez'},{'type' => 'set_option'}, "");
	my $keyspace_source = Set->new('keyspace_source', 1, {'type' => 'meta_option'}, {'entrez' => $entrez});

	my $keyspace = Set->new('keyspace', 1, {'type' => 'meta_option'}, 
		{'keyspace_source' => $keyspace_source, 'keyspace_organism' => $keyspace_organism});

	my $go = Set->new('go', $checkedopts->{'go'}, {'type' => 'set_option'}, "");
	my $curated = Set->new('curated', 1, {'type' => 'meta_option'}, {'go' => $go});

	my $chemdiv = Set->new('chemdiv', $checkedopts->{'chemdiv'}, {'type' => 'set_option'}, "");
	my $boon_sga = Set->new('boon_sga', $checkedopts->{'boon_sga'}, {'type' => 'set_option'}, "");
	my $experimental = Set->new('experimental', 1, {'type' => 'meta_option'}, {'chemdiv' => $chemdiv, 'boon_sga' => $boon_sga});

	my $source = Set->new('source', 1, {'type' => 'meta_option'}, {'experimental' => $experimental, 'curated' => $curated});
	
	my $opts = Set->new('Filter_Options', 1, {'type' => 'meta_option'}, {'keyspace' => $keyspace, 'source' => $source});
	my @opts = ($opts);

	# end build options

	## Create Form element and the rest...
	print <<MULTILINE_STR;
	<form id="searchcategories">
	<b> Filter: </b><input type='text' name="searchtext" value="$searchtext" size="25">
	<!-- Send selected filter categories to display pannel via ajax -->
	<input type='button' name='activetab' value='filter' onClick="return onSearchSets();">
	<div>&nbsp;</div>
MULTILINE_STR


	MySets::displaySetsTree("search_opts", "", @opts);
	#print @checked;

	my $checkedopts;
	my $FULL_SEARCH = $TRUE;

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
