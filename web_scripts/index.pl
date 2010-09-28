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
use lib "/var/www/cgi-bin/BEAST/perllib";
use utils;		  #contains useful, simple functions such as trim, max, min, and log_base
use htmlHelper;

# don't have permission to install, so this has to be packaged
use CGI::Session;
use BEAST::CheckBoxTree;
use BEAST::SearchTab;
use BEAST::BrowseTab;
use BEAST::ImportTab;
use BEAST::ViewTab;
use BEAST::CollectionsTab;
use BEAST::MySets;
use BEAST::Set;
use BEAST::ClusteredCollection;
use BEAST::BeastSession;
use BEAST::DebugHelper;

# global variable
our $cgi = new CGI();

my $sid = $cgi->cookie("CGISESSID") || undef;
### restore their session, or create a new one if it doesn't exist yet
our $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
$session->expire('+1h');
#
### save sid in the users cookie
our $cookie = $cgi->cookie(CGISESSID => $session->id);
print $cgi->header( -cookie=>$cookie );

our @sets;

my $searchObj = SearchTab->new($cgi);
my $importObj = ImportTab->new($cgi);
my $browseObj = BrowseTab->new($cgi);
my $collectionsObj = CollectionsTab->new($cgi);
my $viewObj = ViewTab->new($cgi);
my $mysetsObj = MySets->new($cgi);
	
#print Data::Dumper->Dump([$cgi]);
#main
{
	#print $cgi->header();

	# debug

	#print `cat /proc/meminfo`;
	#print `cat /proc/cpuinfo`;
	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	my $action = $cgi->param('action');

	# the following is one gigantic switch staeement on the 'action' param

	# this is the one exception, for the AJAX file upload
	if ($cgi->param('my_upload_file'))
	{
		my $fh = $cgi->upload('my_upload_file');
		$importObj->printTab($session, $fh);
	}
	elsif ($action eq "addsearch")
	{
		addSearchSets();
		displayMySets($cgi);
	}
	elsif ($action eq "addbrowse")
	{
		addBrowseSets();
		displayMySets($cgi);
	}
	elsif ($action eq "addimportfile")
	{
		addImportSets();
		displayMySets($cgi);
	}
	elsif ($action eq "search")
	{
		# replace the search tab to include the search results

		$searchObj->printTab($session);
		unless ($cgi->param('searchtext')) {
			$browseObj->printTab($session);
		}
	}
	elsif ($action eq "import")
	{
		$importObj->printTab($session);
	}
	elsif ($action eq "browse")
	{
		$browseObj->printTab($session);
	}
	elsif ($action eq "browse_dig")
	{
		$browseObj->dig($session);
	}
	elsif ($action eq "get_set_elements")
	{
		my @entities = getEntitiesForSet($session, $cgi->param('db_id'));
		my $margin = $cgi->param('depth') * 10;
		print "<span style=\"margin-left:".$margin."px;\" >";
		foreach (@entities) {
			print $_."&nbsp;";
		}
		print "</span>";
	}
	elsif ($action eq "heatmap")
	{
		$viewObj->printTab($session, $cgi->param('type'));
	}
	elsif ($action eq "column_highlight")
	{
		my $gifInfo = BeastSession::getHeatmapInfoFromSession($session);
		my $column = ViewTab::getColumn($gifInfo, $cgi->param('x_coord'), $cgi->param('y_coord'));
		my $selected = { $column => 1 };
		BeastSession::saveSelectedColumns($session, $selected);
		$mysetsObj->printTabFlat($session);
	}
	elsif ($action eq "clear")
	{
		$session->clear('mysets');
		$session->clear('mycollections');
		$session->clear('collectionX');
		$session->clear('collectionY');
	}
	elsif ($action eq "mysets")
	{
		if ($cgi->param('format') && ($cgi->param('format') eq 'json')) {
			getMySetsJSON();		
		}

		if ($cgi->param('type') eq 'tree') {
			$mysetsObj->printTabTree($session);
		} elsif ($cgi->param('type') eq 'flat') {
			$mysetsObj->printTabFlat($session);
		}
	}
	elsif ($action eq "mycollections")
	{
		$collectionsObj->printTab($session);
	}
	elsif ($action eq "addcollection")
	{
		addCollection();
		$mysetsObj->printTabTree($session);
	}
	elsif ($action eq "updatecollections")
	{
		updateActiveCollections();
		$collectionsObj->printTab($session);
	} 
	elsif ($action eq "add_set_from_op")
	{
		addSetFromOp();
		$mysetsObj->printTabTree($session);
	} 
	# on new load

#	DebugHelper::printRequestParameters($cgi);


	#my $activetab = $cgi->param('tab');	
	#my $selected = 1;
	#if ($activetab == 'search') {
	#	$selected = 2;
	#}

}# end main

sub displayMySets()
{
	if ($cgi->param('type') eq "tree") {
		$mysetsObj->printTabTree($session);
	}  else {
		$mysetsObj->printTabFlat($session);
	}
}

# save and merge search results to mysets
sub getMySetsJSON()
{
	@sets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1, "", ""));
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	my @leaves;
	foreach (@sets) {
		push @leaves, $_->getLeafNodes();
	}

	my $elements = {};
	foreach (@leaves) {
		$elements->{$_->get_name} = $_;
	}

	my $collection = Set->new('collection', 1, {}, $elements);

	print $collection->serialize();
}

sub addSetFromOp()
{
	my $operation = $cgi->param('operation');
	my $new_set_name = $cgi->param('name');
	my @checkboxdata = $cgi->param('checkedfilters[]');

	# load the checked sets, perform the operation and generate a new set based on it called: new_set
	# note: we have to load the elements for these sets into memory, which means this is a bit slower
	my @workspace_leaf_sets = BeastSession::loadMergeLeafSets($session, 'mysets', \@checkboxdata, 1);
	unless (ref($workspace_leaf_sets[0]) eq 'Set') {
		pop @workspace_leaf_sets;
	}

	my $newSet;
	if ($operation eq "union") {
		$newSet = Set::generateSetsUnion($new_set_name, @workspace_leaf_sets);
	} elsif ($operation eq "intersection") {
		$newSet = Set::generateSetsIntersection($new_set_name, @workspace_leaf_sets);
	}
	unless (ref($newSet) eq 'Set') {
		# something went wrong: hopefully the Set function reported it to stdout...
		return 0;
	}

	## Load all the user sets: if they have ImportSets already created, add it there; otherwise 
	## create the import sets tab and add it (this is essentially the same code as in 'addImportSets'
	my @all_sets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1, "", ""));
	unless (ref($all_sets[0]) eq 'Set') {
		pop @all_sets;
	}

	my @mergedSets;
	# add the source, organism
	my $organism = $cgi->param('organism');
	my $source = $cgi->param('source');

	# generate the top level set
	my $metadata = { 'type' => 'meta' };
	my $elements = {$new_set_name => $newSet};
	my $importSet = Set->new('ImportSets', "1", $metadata, $elements);
	my @array;
	push @array, $importSet;

	if (scalar(@all_sets) == 0) {
		@mergedSets = @array;
	} else {
		my $already_contains_import = 0;
	 	foreach my $set (@all_sets) {
			my @tmp = ($set);
			if ($set->get_name eq 'ImportSets') {
				#my @importedSets = Set::mergeDisjointCollections(\@tmp, \@array);
				my @importedSets = Set::mergeDisjointCollections(\@array, \@tmp);
				push @mergedSets, $importedSets[0];
				$already_contains_import = 1;
			} else {
				# add to the new set
				push @mergedSets, $set;
			}
		}
		if ($already_contains_import == 0) {
			push @mergedSets, $importSet;
		}	
	}

	return unless (scalar(@mergedSets) > 0);
	BeastSession::saveObjsToSession($session, 'mysets', @mergedSets);
}

sub addSearchSets()
{
	@sets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1, "", ""));
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	#print Data::Dumper->Dump([@sets]);

	# add/merge these sets with the current working sets
	if ($cgi->param('searchsets[]')) {
		my @checkboxdata = $cgi->param('searchsets[]');
		my @searchSets = BeastSession::loadMergeSetsFromSession($session, 'searchsets', \@checkboxdata);
		#print Data::Dumper->Dump([@searchSets]);
		if (scalar(@sets) == 0) {
			@sets = @searchSets;
		} else {
			# fixme: checkbox conflicts for searchSets should resolve to overriding by new SearchSets
			@sets = Set::mergeDisjointCollections(\@sets, \@searchSets);
		}
	}
	return unless (scalar(@sets) > 0);
	BeastSession::saveObjsToSession($session, 'mysets', @sets);
}

sub addBrowseSets()
{
	@sets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1, "", ""));
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	# add/merge these sets with the current working sets
	if ($cgi->param('browsesets[]')) {
		# set of internal database ID's
		my @checkboxdata = $cgi->param('browsesets[]');

		my $beastDB = BeastDB->new;
		$beastDB->connectDB();
		my $treeBuilder = Search->new($beastDB);

		my @browseSets = $treeBuilder->getSetsByIds(@checkboxdata);
		$beastDB->disconnectDB();

		if (scalar(@sets) == 0) {
			@sets = @browseSets;
		} else {
			@sets = Set::mergeDisjointCollections(\@sets, \@browseSets);
		}

	}
	return unless (scalar(@sets) > 0);
	BeastSession::saveObjsToSession($session, 'mysets', @sets);
}

sub getEntitiesForSet
{
	my $session = shift;
	my $id = shift;

	my $entities;

	if ($id =~ /^local_.*/) {

		my @importSets = BeastSession::loadImportSetsFromSession($session);
		unless (ref($importSets[0]) eq 'Set') {
			pop @importSets;
		}

		foreach (@importSets) {
			my $set = $_;
			if ($set->get_id eq $id) {
				my @ents = $set->get_element_names;
				return @ents;
			}
		}

	} else {
		my $beastDB = BeastDB->new;
		$beastDB->connectDB();

		$entities = $beastDB->getEntityNameValuesForSet($id);
		$beastDB->disconnectDB();
	}

	my @list;
	foreach (keys %$entities) {
		if ($entities->{$_} =~ /\d?\.\d+/) {
			push @list, "$_:".$entities->{$_};
		} else {
			push @list, $_;	
		}
	}

	return @list;
}

sub updateActiveCollections()
{
	my $XName = $cgi->param('collectionX');
	my $YName = $cgi->param('collectionY');

	my $colX;
	my $colY;

	my @collections = BeastSession::loadObjsFromSession($session, 'mycollections', ClusteredCollection->new('constructor', ""));
	unless (ref($collections[0]) eq 'ClusteredCollection') {
		pop @collections;
	}

	# note: it is perfectly valid for X/Y to be the same collection (don't use elsif)
	foreach my $col (@collections) {
		if ($col->get_name eq $XName) {
			$colX = $col;
		}
		if ($col->get_name eq $YName) {
			$colY = $col;
		}

	}

	# all kinds of error checking
	unless ($colX) {
		print "Error: $XName not a valid collection!";
		return 0;
	}
	unless ($colY) {
		print "Error: $YName not a valid collection!";
		return 0;
	}

	unless ($colX->get_keyspace_source eq $colY->get_keyspace_source) {
		print "Error: Collections don't have the same keyspace source!";
		return 0;
	}
	unless ($colX->get_keyspace_organism eq $colY->get_keyspace_organism) {
		print "Error: Collections don't have the same keyspace organism!";
		return 0;
	}
	

	BeastSession::saveSelectedCollections($session, $XName, $YName);
}

sub addCollection()
{
	my @checkboxdata = $cgi->param('checkedfilters[]');
	my $name = $cgi->param('name');
	my @collectionSets = BeastSession::loadMergeLeafSets($session, 'mysets', \@checkboxdata);
	if (scalar(@collectionSets) == 0) {
		print "Error: no sets found for collection!";
		return 0;
	}
	my $newCollection = ClusteredCollection->new($name, @collectionSets);

	# force all sets in the collection to have a single keyspace, and set it
	my $keyspace_organism;
	my $keyspace_source;
	foreach my $set (@collectionSets) {
		unless ($keyspace_source) {
			$keyspace_source = $set->get_keyspace_source();
		}
		unless ($keyspace_organism) {
			$keyspace_organism = $set->get_organism();
		}

		unless ($keyspace_organism eq $set->get_organism() && $keyspace_source eq $set->get_keyspace_source()) {
			print "Error: sets for a given collection must have the same keyspace!";
			print "$keyspace_organism $keyspace_source";
			return 1;
		}
	}
	
	# store the keyspace info for collections, it's used by other functions to check the 
	# validity of collection operations
	$newCollection->set_keyspace_source($keyspace_source);
	$newCollection->set_keyspace_organism($keyspace_organism);
	
	# assuming homosets, get the source for any set to determine the 
	# source and keyspace
	# likewise get the keyspace for 
	#my $source = $collectionSets[0]->get_source;
	#my $organism = $collectionSets[0]->get_keyspace_organism;
	#$newCollection->set_source($source);
	#$newCollection->set_organism($organism);

	# add to the existing collections
	my @collections = BeastSession::loadObjsFromSession($session, 'mycollections', ClusteredCollection->new('constructor', ""));
	unless (ref($collections[0]) eq 'ClusteredCollection') {
		pop @collections;
	}
	push @collections, $newCollection;

	BeastSession::saveObjsToSession($session, 'mycollections', @collections);
}

sub addImportSets()
{
	@sets = BeastSession::loadObjsFromSession($session, 'mysets', Set->new('constructor', 1, "", ""));
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	#print Data::Dumper->Dump([@sets]);

	my @mergedSets;
	# add/merge these sets with the current working sets
	if ($cgi->param('importsets[]')) {
		my @checkboxdata = $cgi->param('importsets[]');
		my @importSets = BeastSession::loadMergeSetsFromSession($session, 'importsets', \@checkboxdata);

		# add the source, organism
		my $organism = $cgi->param('organism');
		my $source = $cgi->param('source');

		# generate the top level set
		my $metadata = { 'type' => 'meta' };
		my $elements = {};
		foreach my $set (@importSets) {
			$set->set_source("user_import");
			$set->set_keyspace_source($source);	
			$set->set_organism($organism);
			$elements->{$set->get_name} = $set;
		}
		my $importSet = Set->new('ImportSets', "1", $metadata, $elements);
		my @array;
		push @array, $importSet;

		if (scalar(@sets) == 0) {
			@mergedSets = @array;
		} else {
			my $already_contains_import = 0;
		 	foreach (@sets) {
				my $set = $_;
				my @tmp = ($set);
				if ($set->get_name eq 'ImportSets') {
					#my @importedSets = Set::mergeDisjointCollections(\@tmp, \@array);
					my @importedSets = Set::mergeDisjointCollections(\@array, \@tmp);
					push @mergedSets, $importedSets[0];
					$already_contains_import = 1;
				} else {
					# add to the new set
					push @mergedSets, $set;
				}
			}
			if ($already_contains_import == 0) {
				push @mergedSets, $importSet;
			}	
		}
	}
	return unless (scalar(@mergedSets) > 0);
	BeastSession::saveObjsToSession($session, 'mysets', @mergedSets);
}


