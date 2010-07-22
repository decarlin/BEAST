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
use BEAST::MySets;
use BEAST::Set;
use BEAST::BeastSession;

use constant DEBUG => 1;

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
		if ($cgi->param('type') eq "tree") {
			displayMySetsTree();
		}
	}
	elsif ($cgi->param('addimportfile'))
	{
		addImportSets();
		if ($cgi->param('type') eq "tree") {
			displayMySetsTree();
		} 
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
		if ($cgi->param('format') && ($cgi->param('format') eq 'json'))
		{
			getMySetsJSON();		
		}
		else
		{
			displayMySetsTree();
		}
	}
	else
	{
		# default; on page creation	
		$session->clear();
#		doTabbedMenu();	
	}

	if(DEBUG)
	{
		print "<table><tr><th colspan=2>CGI Parameters</th></tr><tr><th>name</th><th>value</th></tr>";
		my @names = $cgi->param;
		foreach my $name (@names)
		{
			print "<tr><td>$name</td><td>".$cgi->param($name)."</td></tr>\n";
		}
		print "</table>";
	}
	#my $activetab = $cgi->param('tab');	
	#my $selected = 1;
	#if ($activetab == 'search') {
	#	$selected = 2;
	#}

}# end main



sub displayMySetsFlat()
{
	@sets = BeastSession::loadSetsFromSession($session, 'mysets');
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}

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
	print "<input type='button' value='Update' onClick=\"return onUpdateMySets(this.form);\"><br>";
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
		if ($#sets == -1) {
			@sets = @searchSets;
		} else {
			@sets = Set::mergeDisjointCollections(\@sets, \@searchSets);
		}
	}
	return unless (scalar(@sets) > 0);
	BeastSession::saveSetsToSession($session, 'mysets', @sets);
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


