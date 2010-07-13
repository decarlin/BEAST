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
use BEAST::BrowseTab;
use BEAST::ImportTab;
use BEAST::MySets;
use BEAST::Set;
use BEAST::BeastSession;

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

sub doTabbedMenu();
sub doImportTab();

my $browseObj;
my $importObj;

#main
{
	#print $cgi->header();

	# debug

	#run some query, get the set of categories	
	#@my $sql = 
	#$results = runSQL($sql, $dbh);

	$browseObj = BrowseTab->new($cgi);
	$importObj = ImportTab->new($cgi);

	if ($cgi->param('addbrowse')) {
		addSearchSets();
		if ($cgi->param('type') eq "tree") {
			displayMySets();
		}
	} elsif ($cgi->param('browse')) {
		# replace the browse tab to include the search results

		$browseObj->printBrowseTab($session);
	} elsif ($cgi->param('import')) {
		$importObj->printImportTab();
	} elsif ($cgi->param('display_mysets_tree')) {
		displayMySets();
	} elsif ($cgi->param('mysets')) {
		displayMySets();
	} else {
		# default; on page creation	
		$session->clear();
		doTabbedMenu();	
	}

	#my $activetab = $cgi->param('tab');	
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
			\$("#tabs").tabs({

	  		select: function(event, ui) {
				onOpsTabSelected(event, ui);
    			}
			});
			\$("#mysets_tab").tabs({

	  		select: function(event, ui) {
				onViewTabSelected(event, ui);
    			}
			});
		}
	);
</script>

<div class="mysets_div" id="mysets_tab">
	<ul>
		<li><a href="#mysets_tree">MySets (Tree)</a></li>
		<li><a href="#mysets_flat">MySets (Flat)</a></li>
	</ul>
	<div id="mysets_tree">
MULTILINE_STR
	displayMySets();
# mysets
	print <<MULTILINE_STR;
	</div>
	<div id="mysets_flat">
MULTILINE_STR

print "</div>";
# surrounding div
print "</div>";

print <<MULTILINE_STR;
<div class="myopstabs_div" id="tabs">
	<ul>
		<li><a href="#import">Import</a></li>
		<li><a href="#browse">Browse</a></li>
		<li><a href="#view">View</a></li>
		<li><a href="http://sysbio.soe.ucsc.edu/BEAST/admin_pages/admin.html">Admin</a></li>
	</ul>
MULTILINE_STR

	print "<div id=\"import\">";
	$importObj->printImportTab();
	print `hostname -f`;
	print "</div>";

	print "<div id=\"browse\">";
	$browseObj->printBrowseTab();
	print "</div>";

	print "<div id=\"view\">";
	print "</div>";

	print "<div id=\"admin\">";
	print "</div>";
print "</div>";
}

sub displayMySets()
{
	@sets = BeastSession::loadMySets($session);
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}

	print "<form id=\"mysetsform\">";
	print "<input type='button' value='Update' onClick=\"return onUpdateMySets(this.form);\"><br>";
	if ($cgi->param('checkedelements[]')) {
		my @checked = $cgi->param('checkedelements[]');	
		my $checked_hash = BeastSession::buildCheckedHash(@checked);
		#print Data::Dumper->Dump([$checked_hash]);
		@sets = MySets::updateActiveElements($checked_hash, @sets);	
		BeastSession::saveMySets($session, @sets);
	}
	MySets::displaySets("mysets", @sets);
	print "</form>";
}


# save and merge search results to mysets
sub addSearchSets()
{
	@sets = BeastSession::loadMySets($session);
	unless (ref($sets[0]) eq 'Set') {
		pop @sets;
	}
	#print Data::Dumper->Dump([@sets]);

	# add/merge these sets with the current working sets
	if ($cgi->param('browsesets[]')) {
		my @browseSets = BeastSession::loadSearchResults($session, $cgi);
		if ($#sets == -1) {
			@sets = @browseSets;
		} else {
			@sets = Set::mergeDisjointCollections(\@sets, \@browseSets);
		}
	}
	BeastSession::saveMySets($session, @sets);
}


