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

# don't have permission to install, so this has to be packaged
use CGI::Session;
use BEAST::CheckBoxTree;
use BEAST::SearchTab;
use BEAST::BrowseTab;
use BEAST::ImportTab;
use BEAST::ViewTab;
use BEAST::MySets;
use BEAST::Set;
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
my $viewObj = ViewTab->new($cgi);
	
#print Data::Dumper->Dump([$cgi]);
#main
{
	#print $cgi->header();

	# debug

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	my $action = $cgi->param('action');

	if ($cgi->param('my_upload_file'))
	{
		my $fh = $cgi->upload('my_upload_file');
		$importObj->printTab($session, $fh);
	}
	elsif ($cgi->param('addsearch'))
	{
		addSearchSets();
		displayMySets($cgi);
	}
	elsif ($cgi->param('addbrowse'))
	{
		addBrowseSets();
		displayMySets($cgi);
	}
	elsif ($cgi->param('addimportfile'))
	{
		addImportSets();
		displayMySets($cgi);
	}
	elsif ($action eq "search")
	{
		# replace the search tab to include the search results

		$searchObj->printTab($session);
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
		my @entities = getEntitiesForSet($cgi->param('db_id'));
		my $margin = $cgi->param('depth') * 10;
		print "<span style=\"margin-left:".$margin."px;\" >";
		foreach (@entities) {
			print $_."&nbsp;";
		}
		print "</span>";
	}
	elsif ($action eq "heatmap")
	{
		$viewObj->printTab($session);
	}
	elsif ($cgi->param('display_mysets_tree'))
	{
		displayMySetsTree();
	}
	elsif ($cgi->param('display_mysets_flat'))
	{
		displayMySetsFlat();
	}
	elsif ($cgi->param('mysets'))
	{
		if ($cgi->param('mysets') eq 'clear') {
			my @list = ('mysets');
			$session->clear([@list]);
			displayMySetsTree();
		}
		if ($cgi->param('format') && ($cgi->param('format') eq 'json'))
		{
			getMySetsJSON();		
		}
		else
		{
			displayMySetsTree();
		}
	}
	elsif ($action eq 'clear') {
		$session->clear();
	}

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
		displayMySetsTree();
	}  else {
		displayMySetsFlat();
	}
}

sub displayMySetsFlat()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}

	return unless (scalar(@sets) > 0); 

	print "<form id=\"mysetsform_flat\">";
	MySets::displaySetsFlat("mysets", @sets);
	print "</form>";
}

sub displayMySetsTree()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}

	return unless (scalar(@sets) > 0); 

	print "<form id=\"mysetsform\">";
	print "<input type='button' value='Update' onClick=\"return onUpdateMySets(this.form);\">";
	print "<input type='button' value='Clear' onClick=\"return onClearMySets();\"><br>";
	if ($cgi->param('checkedelements[]')) {
		my @checked = $cgi->param('checkedelements[]');	
		my $checked_hash = BeastSession::buildCheckedHash(@checked);
		#print Data::Dumper->Dump([$checked_hash]);
		@sets = MySets::updateActiveElements($checked_hash, @sets);	
		BeastSession::saveSetsToSession($session, 'mysets', @sets);
	}
	MySets::displaySetsTree("mysets", @sets);
	print "</form>";
}


# save and merge search results to mysets
sub getMySetsJSON()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
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

sub addSearchSets()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	#print Data::Dumper->Dump([@sets]);

	# add/merge these sets with the current working sets
	if ($cgi->param('searchsets[]')) {
		my @checkboxdata = $cgi->param('searchsets[]');
		my @searchSets = BeastSession::loadMergeSetsFromSession($session, 'searchsets', \@checkboxdata);
		if (scalar(@sets) == 0) {
			@sets = @searchSets;
		} else {
			@sets = Set::mergeDisjointCollections(\@sets, \@searchSets);
		}
	}
	return unless (scalar(@sets) > 0);
	BeastSession::saveSetsToSession($session, 'mysets', @sets);
}

sub addBrowseSets()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
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
	BeastSession::saveSetsToSession($session, 'mysets', @sets);
}

sub getEntitiesForSet
{
	my $id = shift;

	my $beastDB = BeastDB->new;
	$beastDB->connectDB();

	my @entities = $beastDB->getEntitiesForSet($id);

	$beastDB->disconnectDB();

	return @entities;
}

sub addImportSets()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	#print Data::Dumper->Dump([@sets]);

	# add/merge these sets with the current working sets
	if ($cgi->param('importsets[]')) {
		my @checkboxdata = $cgi->param('importsets[]');
		my @importSets = BeastSession::loadMergeSetsFromSession($session, 'importsets', \@checkboxdata);
		if (scalar(@sets) == 0) {
			@sets = @importSets;
		} else {
			@sets = Set::mergeDisjointCollections(\@sets, \@importSets);
		}
	}
	return unless (scalar(@sets) > 0);
	BeastSession::saveSetsToSession($session, 'mysets', @sets);
}


